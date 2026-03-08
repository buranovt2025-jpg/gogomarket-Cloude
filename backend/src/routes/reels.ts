import { Router } from 'express';
import { db } from '../db';
import { reels, sellers } from '../db/schema';
import { authenticate } from '../middleware/auth';
import { eq, desc } from 'drizzle-orm';
import { z } from 'zod';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /api/reels — лента рилсов
router.get('/', async (req, res) => {
  const { limit = 20, offset = 0 } = req.query as any;
  const items = await db.select({
    id:         reels.id,
    title:      reels.title,
    videoUrl:   reels.videoUrl,
    thumbUrl:   reels.thumbUrl,
    likeCount:  reels.likeCount,
    viewCount:  reels.viewCount,
    sellerId:   reels.sellerId,
    productId:  reels.productId,
    createdAt:  reels.createdAt,
    shopName:   sellers.shopName,
    logoUrl:    sellers.logoUrl,
  })
  .from(reels)
  .leftJoin(sellers, eq(reels.sellerId, sellers.id))
  .where(eq(reels.status, 'active'))
  .orderBy(desc(reels.viewCount))
  .limit(Number(limit))
  .offset(Number(offset));

  res.json({ items, total: items.length });
});

// POST /api/reels — создать рилс (продавец)
router.post('/', authenticate, async (req, res) => {
  const body = z.object({
    videoUrl:  z.string().url(),
    thumbUrl:  z.string().url().optional(),
    title:     z.string().min(1).max(300),
    productId: z.string().uuid().optional(),
  }).parse(req.body);

  // Находим продавца
  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId));
  if (!seller) throw new AppError(403, 'Seller profile not found');

  const [reel] = await db.insert(reels).values({
    ...body,
    sellerId:  seller.id,
    status:    'active',
    likeCount: 0,
    viewCount: 0,
  }).returning();

  res.status(201).json(reel);
});

// POST /api/reels/:id/view — засчитать просмотр
router.post('/:id/view', async (req, res) => {
  const [reel] = await db.select().from(reels).where(eq(reels.id, String(req.params.id)));
  if (reel) {
    await db.update(reels).set({ viewCount: (reel.viewCount || 0) + 1 })
      .where(eq(reels.id, String(req.params.id)));
  }
  res.json({ ok: true });
});

// POST /api/reels/:id/like
router.post('/:id/like', authenticate, async (req, res) => {
  const [reel] = await db.select().from(reels).where(eq(reels.id, String(req.params.id)));
  if (!reel) throw new AppError(404, 'Reel not found');
  await db.update(reels).set({ likeCount: (reel.likeCount || 0) + 1 })
    .where(eq(reels.id, String(req.params.id)));
  res.json({ likeCount: (reel.likeCount || 0) + 1 });
});

export default router;
