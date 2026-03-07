import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { users } from '../db/schema';
import { authenticate } from '../middleware/auth';
import { eq } from 'drizzle-orm';

const router = Router();

// POST /v1/push/token — save FCM token
router.post('/token', authenticate, async (req, res) => {
  const { token } = z.object({ token: z.string().min(10) }).parse(req.body);
  await db.update(users)
    .set({ fcmToken: token, updatedAt: new Date() } as any)
    .where(eq(users.id, req.user!.userId));
  res.json({ ok: true });
});

export default router;
