import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { sellers, products, reels, orders, orderItems, users, notifications } from '../db/schema';
import { authenticate, requireSeller } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';
const upload = multer({ dest: 'uploads/verification/' });
import { eq, and, desc, gte, sql } from 'drizzle-orm';

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

// GET /v1/sellers/me/limits — weekly usage for tier 2 sellers
router.get('/me/limits', authenticate, requireSeller, async (req, res) => {
  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller) throw new AppError(404, 'Seller not found');

  const userTier = req.user!.tier ?? 1;
  const weekAgo  = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

  // Count products created this week
  const [{ productCount }] = await db.select({ productCount: sql<number>`count(*)::int` })
    .from(products)
    .where(and(eq(products.sellerId, seller.id), gte(products.createdAt, weekAgo)));

  // Count reels created this week
  const [{ reelCount }] = await db.select({ reelCount: sql<number>`count(*)::int` })
    .from(reels)
    .where(and(eq(reels.sellerId, seller.id), gte(reels.createdAt, weekAgo)));

  // Count stories today
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  // Upcoming expirations — listings expiring in next 3 days
  const in3days = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000);
  const { listingExpirations } = await import('../db/schema');
  const { lte, isNull } = await import('drizzle-orm');

  const expiringSoon = await db.select().from(listingExpirations)
    .where(and(
      eq(listingExpirations.userId, req.user!.userId),
      lte(listingExpirations.expiresAt, in3days),
      isNull(listingExpirations.deletedAt),
    ));

  if (userTier === 2) {
    return res.json({
      tier: 2,
      products: { used: productCount,  limit: 10, resetsIn: _msUntilWeekReset() },
      reels:    { used: reelCount,      limit: 3,  resetsIn: _msUntilWeekReset() },
      stories:  { used: 0,              limit: 1,  resetsIn: _msUntilDayReset()  },
      expiringSoon: expiringSoon.map(e => ({
        type: e.listingType,
        id:   e.listingId,
        expiresAt: e.expiresAt,
        daysLeft: Math.max(0, Math.ceil((e.expiresAt.getTime() - Date.now()) / (24 * 60 * 60 * 1000))),
      })),
    });
  }

  // Tier 3 — unlimited
  return res.json({
    tier: userTier,
    products: { used: productCount, limit: null },
    reels:    { used: reelCount,    limit: null },
    stories:  { used: 0,            limit: null },
    expiringSoon: [],
  });
});

function _msUntilWeekReset(): number {
  const now = new Date();
  const nextMonday = new Date(now);
  nextMonday.setDate(now.getDate() + (8 - now.getDay()) % 7 || 7);
  nextMonday.setHours(0, 0, 0, 0);
  return nextMonday.getTime() - now.getTime();
}

function _msUntilDayReset(): number {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  return tomorrow.getTime() - Date.now();
}

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

// GET /v1/sellers/analytics?days=7
router.get('/analytics', authenticate, requireSeller, async (req, res) => {
  const days = Math.min(parseInt(String(req.query.days ?? '7')), 90);
  const since = new Date(Date.now() - days * 24 * 3600 * 1000);

  // Get seller record
  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller) throw new AppError(404, 'Seller not found');

  // Revenue and orders
  const sellerOrders = await db.select({
    id:          orders.id,
    totalTiyin:  orders.totalTiyin,
    status:      orders.status,
    createdAt:   orders.createdAt,
  }).from(orders)
    .where(and(eq(orders.sellerId, seller.id), gte(orders.createdAt, since)));

  const doneOrders = sellerOrders.filter(o => o.status === 'done' || o.status === 'confirmed');
  const revenue = doneOrders.reduce((sum, o) => sum + Number(o.totalTiyin), 0);

  // Group by day for chart
  const chart: Record<number, { revenue: number; orders: number }> = {};
  for (let i = 0; i < days; i++) chart[i] = { revenue: 0, orders: 0 };

  for (const order of doneOrders) {
    const dayIdx = Math.floor((order.createdAt!.getTime() - since.getTime()) / (24 * 3600 * 1000));
    if (chart[dayIdx]) {
      chart[dayIdx].revenue += Number(order.totalTiyin);
      chart[dayIdx].orders  += 1;
    }
  }

  // Top products
  const topProducts = await db.execute(sql`
    SELECT p.title, COUNT(oi.id) as orders, SUM(oi.price_tiyin * oi.quantity) as revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    WHERE p.seller_id = ${seller.id}
      AND oi.created_at >= ${since}
    GROUP BY p.id, p.title
    ORDER BY orders DESC
    LIMIT 5
  `).catch(() => ({ rows: [] }));

  res.json({
    revenue,
    revenueGrowth: 0,
    orders:        sellerOrders.length,
    ordersGrowth:  0,
    views:         0,
    viewsGrowth:   0,
    conversion:    sellerOrders.length > 0 ? (doneOrders.length / sellerOrders.length * 100) : 0,
    chart:         Object.entries(chart).map(([day, v]) => ({ day: parseInt(day), ...v })),
    topProducts:   (topProducts as any).rows ?? [],
  });
});
