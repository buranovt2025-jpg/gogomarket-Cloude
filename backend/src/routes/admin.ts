import { Router } from 'express';
import { db } from '../db';
import { sellers, users, orders, products, auditLogs } from '../db/schema';
import { authenticate, requireAdmin } from '../middleware/auth';
import { eq, desc, count, sql } from 'drizzle-orm';
import { z } from 'zod';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Все admin routes требуют авторизацию + admin роль
router.use(authenticate, requireAdmin);

// GET /api/admin/dashboard
router.get('/dashboard', async (_req, res) => {
  const [userCount]      = await db.select({ count: count() }).from(users);
  const [sellerCount]    = await db.select({ count: count() }).from(sellers).where(eq(sellers.isVerified, true));
  const [orderCount]     = await db.select({ count: count() }).from(orders);
  const [pendingSellers] = await db.select({ count: count() }).from(sellers).where(eq(sellers.isVerified, false));
  const [revenue]        = await db.select({ total: sql<number>`COALESCE(SUM(total_amount), 0)` })
    .from(orders).where(eq(orders.status, 'delivered'));

  res.json({
    users:               userCount.count,
    sellers:             sellerCount.count,
    orders:              orderCount.count,
    pendingVerifications: pendingSellers.count,
    totalRevenue:        revenue.total,
  });
});

// GET /api/admin/sellers/pending
router.get('/sellers/pending', async (_req, res) => {
  const pending = await db.select().from(sellers)
    .where(eq(sellers.isVerified, false))
    .orderBy(desc(sellers.createdAt));
  res.json(pending);
});

// POST /api/admin/sellers/:id/verify
router.post('/sellers/:id/verify', async (req, res) => {
  const { approved, reason } = z.object({
    approved: z.boolean(),
    reason:   z.string().optional(),
  }).parse(req.body);

  const [seller] = await db.update(sellers)
    .set({ isVerified: approved, isRejected: !approved, updatedAt: new Date() })
    .where(eq(sellers.id, String(req.params.id)))
    .returning();

  if (!seller) throw new AppError(404, 'Seller not found');

  await db.insert(auditLogs).values({
    adminId:    req.user!.userId,
    action:     approved ? 'seller_verified' : 'seller_rejected',
    targetType: 'seller',
    targetId:   seller.id,
    after:      { approved, reason },
  });

  res.json({ seller, message: approved ? 'Seller verified' : 'Seller rejected' });
});

// GET /api/admin/content/flagged
router.get('/content/flagged', async (_req, res) => {
  const flagged = await db.select({
    id:         products.id,
    title:      products.title,
    type:       sql<string>`'product'`,
    reason:     sql<string>`'На проверке'`,
    sellerName: sellers.shopName,
    createdAt:  products.createdAt,
  })
  .from(products)
  .leftJoin(sellers, eq(products.sellerId, sellers.id))
  .where(eq(products.status, 'pending'))
  .orderBy(desc(products.createdAt))
  .limit(50);
  res.json(flagged);
});

// PATCH /api/admin/products/:id/moderate
router.patch('/products/:id/moderate', async (req, res) => {
  const { action } = z.object({ action: z.enum(['approve', 'reject']) }).parse(req.body);
  const [product] = await db.update(products)
    .set({ status: action === 'approve' ? 'active' : 'rejected', updatedAt: new Date() })
    .where(eq(products.id, String(req.params.id)))
    .returning();
  res.json(product);
});

// GET /api/admin/orders
router.get('/orders', async (req, res) => {
  const { status, limit = 50 } = req.query as any;
  const where = status ? eq(orders.status, status) : undefined;
  const items = await db.select().from(orders)
    .where(where).orderBy(desc(orders.createdAt)).limit(Number(limit));
  res.json(items);
});

// GET /api/admin/users
router.get('/users', async (req, res) => {
  const { limit = 50, offset = 0 } = req.query as any;
  const allUsers = await db.select({
    id: users.id, name: users.name, phone: users.phone,
    role: users.role, isVerified: users.isVerified, createdAt: users.createdAt,
  }).from(users).orderBy(desc(users.createdAt)).limit(Number(limit)).offset(Number(offset));
  const [total] = await db.select({ count: count() }).from(users);
  res.json({ users: allUsers, total: total.count });
});

// GET /api/admin/finance
router.get('/finance', async (_req, res) => {
  const [stats] = await db.select({
    totalOrders:  count(),
    totalRevenue: sql<number>`COALESCE(SUM(total_amount), 0)`,
  }).from(orders).where(eq(orders.status, 'delivered'));
  const [sellerCount] = await db.select({ count: count() }).from(sellers).where(eq(sellers.isVerified, true));
  res.json({
    totalRevenue:  stats.totalRevenue,
    totalOrders:   stats.totalOrders,
    activeSellers: sellerCount.count,
    pendingPayout: 0,
  });
});

// POST /api/admin/withdrawals/:id/approve
router.post('/withdrawals/:id/approve', async (req, res) => {
  res.json({ message: 'Withdrawal approved', id: req.params.id });
});

export default router;
