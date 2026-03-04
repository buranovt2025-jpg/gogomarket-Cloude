import { Router } from 'express';
import { db } from '../db';
import { notifications } from '../db/schema';
import { authenticate } from '../middleware/auth';
import { eq, and, desc } from 'drizzle-orm';
import { z } from 'zod';

const router = Router();

router.get('/', authenticate, async (req, res) => {
  const q = z.object({ page: z.coerce.number().default(1), limit: z.coerce.number().max(50).default(30) }).parse(req.query);
  const items = await db.select().from(notifications)
    .where(eq(notifications.userId, req.user!.userId))
    .orderBy(desc(notifications.createdAt))
    .limit(q.limit).offset((q.page - 1) * q.limit);
  res.json(items);
});

router.patch('/:id/read', authenticate, async (req, res) => {
  await db.update(notifications)
    .set({ isRead: true, readAt: new Date() })
    .where(and(eq(notifications.id, req.params.id), eq(notifications.userId, req.user!.userId)));
  res.json({ message: 'Marked as read' });
});

router.patch('/read-all', authenticate, async (req, res) => {
  await db.update(notifications)
    .set({ isRead: true, readAt: new Date() })
    .where(eq(notifications.userId, req.user!.userId));
  res.json({ message: 'All notifications marked as read' });
});

export default router;
