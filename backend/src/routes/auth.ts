import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { users, sellers } from '../db/schema';
import { sendOtp, verifyOtp } from '../utils/sms';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt';
import { AppError } from '../middleware/errorHandler';
import { otpRateLimiter } from '../middleware/rateLimiter';
import { authenticate } from '../middleware/auth';
import { eq } from 'drizzle-orm';

const router = Router();

const phoneSchema = z.object({
  phone: z.string().regex(/^\+998[0-9]{9}$/, 'Invalid Uzbek phone number'),
});

// POST /v1/auth/send-otp
router.post('/send-otp', otpRateLimiter, async (req, res) => {
  const { phone } = phoneSchema.parse(req.body);
  await sendOtp(phone);
  res.json({ message: 'OTP sent', ttl: 60 });
});

// POST /v1/auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  const { phone, code, role = 'buyer', name } = z.object({
    phone: z.string(),
    code: z.string().length(4),
    role: z.enum(['buyer', 'seller']).optional(),
    name: z.string().optional(),
  }).parse(req.body);

  const isValid = await verifyOtp(phone, code);
  if (!isValid) throw new AppError(400, 'Invalid or expired OTP');

  // Upsert user
  let [user] = await db.select().from(users).where(eq(users.phone, phone)).limit(1);
  if (!user) {
    [user] = await db.insert(users).values({
      phone,
      name: name || phone,
      role: role || 'buyer',
    }).returning();
  }

  // Create seller profile if needed
  if (role === 'seller' && user.role === 'buyer') {
    await db.update(users).set({ role: 'seller' }).where(eq(users.id, user.id));
    user.role = 'seller';
  }

  const tokenPayload = { userId: user.id, role: user.role };
  const accessToken  = signAccessToken(tokenPayload);
  const refreshToken = signRefreshToken(tokenPayload);

  res.json({ user, accessToken, refreshToken });
});

// POST /v1/auth/refresh
router.post('/refresh', (req, res) => {
  const { refreshToken } = z.object({ refreshToken: z.string() }).parse(req.body);
  const payload = verifyRefreshToken(refreshToken);
  const accessToken = signAccessToken({ userId: payload.userId, role: payload.role });
  res.json({ accessToken });
});

// GET /v1/auth/me
router.get('/me', authenticate, async (req, res) => {
  const [user] = await db.select().from(users)
    .where(eq(users.id, req.user!.userId)).limit(1);
  if (!user) throw new AppError(404, 'User not found');
  res.json(user);
});

export default router;
