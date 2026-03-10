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
// All users register as tier=1. Role is auto-detected for couriers/admins.
router.post('/verify-otp', async (req, res) => {
  const { phone, code, name } = z.object({
    phone: z.string(),
    code:  z.string().length(4),
    name:  z.string().optional(),
  }).parse(req.body);

  const isValid = await verifyOtp(phone, code);
  if (!isValid) throw new AppError(400, 'Invalid or expired OTP');

  // Upsert user — always tier 1 on first registration
  let [user] = await db.select().from(users).where(eq(users.phone, phone)).limit(1);
  if (!user) {
    [user] = await db.insert(users).values({
      phone,
      name: name || phone,
      role: 'buyer',
      tier: 1,
    }).returning();
  }

  const tokenPayload = {
    userId:    user.id,
    role:      user.role,
    tier:      user.tier,
    sellerId:  undefined as string | undefined,
    courierId: undefined as string | undefined,
  };

  // Attach sellerId to token if user has a seller profile
  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, user.id)).limit(1);
  if (seller) tokenPayload.sellerId = seller.id;

  const accessToken  = signAccessToken(tokenPayload);
  const refreshToken = signRefreshToken(tokenPayload);

  res.json({ user: { ...user, tier: user.tier }, accessToken, refreshToken });
});

// POST /v1/auth/refresh
router.post('/refresh', (req, res) => {
  const { refreshToken } = z.object({ refreshToken: z.string() }).parse(req.body);
  const payload = verifyRefreshToken(refreshToken);
  const accessToken = signAccessToken({
    userId:    payload.userId,
    role:      payload.role,
    tier:      payload.tier ?? 1,
    sellerId:  payload.sellerId,
    courierId: payload.courierId,
  });
  res.json({ accessToken });
});

// GET /v1/auth/me
router.get('/me', authenticate, async (req, res) => {
  const [user] = await db.select().from(users)
    .where(eq(users.id, req.user!.userId)).limit(1);
  if (!user) throw new AppError(404, 'User not found');

  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, user.id)).limit(1);

  res.json({ ...user, seller: seller || null });
});

// POST /v1/auth/upgrade-tier
// Upgrade to tier 2 (private seller) — no verification needed
// Upgrade to tier 3 (business) — requires verified seller + active subscription (checked separately)
router.post('/upgrade-tier', authenticate, async (req, res) => {
  const { tier, shopName } = z.object({
    tier:     z.literal(2),   // only tier 2 self-upgrade; tier 3 via subscription flow
    shopName: z.string().min(2).max(120).optional(),
  }).parse(req.body);

  const [user] = await db.select().from(users)
    .where(eq(users.id, req.user!.userId)).limit(1);
  if (!user) throw new AppError(404, 'User not found');

  if (user.tier >= tier) {
    return res.json({ message: 'Already at this tier or higher', tier: user.tier });
  }

  // Update tier
  const [updated] = await db.update(users)
    .set({ tier, updatedAt: new Date() })
    .where(eq(users.id, user.id))
    .returning();

  // Auto-create seller profile if doesn't exist
  let [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, user.id)).limit(1);

  if (!seller) {
    [seller] = await db.insert(sellers).values({
      userId:    user.id,
      shopName:  shopName || user.name || 'Мой магазин',
      plan:      'private',
      isVerified: false,
    }).returning();
  }

  // Issue new token with updated tier
  const accessToken = signAccessToken({
    userId:   user.id,
    role:     updated.role,
    tier:     updated.tier,
    sellerId: seller.id,
  });

  res.json({ tier: updated.tier, seller, accessToken });
});

export default router;
