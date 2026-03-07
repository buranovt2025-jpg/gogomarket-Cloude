import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { sellers, products, reels } from '../db/schema';
import { authenticate, requireSeller } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { eq, and, desc } from 'drizzle-orm';

const router = Router();

// GET /v1/sellers/:id — public storefront
router.get('/:id', async (req, res) => {
  const [seller] = await db.select().from(sellers).where(eq(sellers.id, String(req.params.id))).limit(1);
  if (!seller) throw new AppError(404, 'Seller not found');

  const sellerProducts = await db.select().from(products)
    .where(and(eq(products.sellerId, seller.id), eq(products.status, 'active')))
    .orderBy(desc(products.createdAt)).limit(20);

  const sellerReels = await db.select().from(reels)
    .where(and(eq(reels.sellerId, seller.id), eq(reels.status, 'active')))
    .orderBy(desc(reels.createdAt)).limit(10);

  res.json({ ...seller, products: sellerProducts, reels: sellerReels });
});

// GET /v1/sellers/me/dashboard
router.get('/me/dashboard', authenticate, requireSeller, async (req, res) => {
  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller) throw new AppError(404, 'Seller profile not found');
  res.json({ seller });
});

// PATCH /v1/sellers/me
router.patch('/me', authenticate, requireSeller, async (req, res) => {
  const updates = z.object({
    shopName:    z.string().min(2).max(120).optional(),
    description: z.string().max(2000).optional(),
    logoUrl:     z.string().url().optional(),
  }).parse(req.body);

  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller) throw new AppError(404, 'Seller not found');

  const [updated] = await db.update(sellers).set(updates)
    .where(eq(sellers.id, seller.id)).returning();
  res.json(updated);
});

// POST /v1/sellers/register
router.post('/register', authenticate, async (req, res) => {
  const body = z.object({
    shopName:    z.string().min(2).max(120),
    inn:         z.string().length(9),
    passportUrl: z.string().url().optional(),
  }).parse(req.body);

  const existing = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (existing.length) throw new AppError(409, 'Seller profile already exists');

  const [seller] = await db.insert(sellers).values({
    userId: req.user!.userId,
    ...body,
  }).returning();

  res.status(201).json(seller);
});

export default router;

// POST /v1/sellers/verification — подача документов на верификацию
router.post('/verification', authenticate, upload.fields([
  { name: 'passportFront', maxCount: 1 },
  { name: 'passportBack',  maxCount: 1 },
  { name: 'selfie',        maxCount: 1 },
]), async (req, res) => {
  const { inn, fullName } = z.object({
    inn:      z.string().min(9).max(9),
    fullName: z.string().min(5),
  }).parse(req.body);

  const files = req.files as Record<string, Express.Multer.File[]>;

  // Save to seller record
  await db.update(sellers).set({
    inn,
    verificationStatus: 'pending',
    verificationMeta: {
      fullName,
      passportFront: files.passportFront?.[0]?.filename,
      passportBack:  files.passportBack?.[0]?.filename,
      selfie:        files.selfie?.[0]?.filename,
      submittedAt:   new Date().toISOString(),
    },
    updatedAt: new Date(),
  } as any).where(eq(sellers.userId, req.user!.userId));

  // Notify admins
  const adminUsers = await db.select().from(users).where(eq(users.role, 'admin')).limit(5);
  for (const admin of adminUsers) {
    await db.insert(notifications).values({
      userId:  admin.id,
      type:    'system',
      title:   'Новая заявка на верификацию',
      body:    `${fullName} (ИНН: ${inn}) подал документы`,
      data:    { sellerId: req.user!.userId },
    } as any).catch(() => {});
  }

  res.json({ ok: true, message: 'Документы приняты, ожидайте проверки' });
});
