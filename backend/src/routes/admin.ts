import { Router } from 'express';
import { db } from '../db';
import { sellers, users, orders, products, disputes, auditLogs } from '../db/schema';
import { authenticate, requireAdmin } from '../middleware/auth';
import { eq, desc, count, sql } from 'drizzle-orm';
import { z } from 'zod';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// All admin routes require auth + admin role
router.use(authenticate, requireAdmin);

// GET /v1/admin/dashboard
router.get('/dashboard', async (_req, res) => {
  const [userCount]   = await db.select({ count: count() }).from(users);
  const [sellerCount] = await db.select({ count: count() }).from(sellers).where(eq(sellers.isVerified, true));
  const [orderCount]  = await db.select({ count: count() }).from(orders);
  const [pendingSellers] = await db.select({ count: count() }).from(sellers)
    .where(eq(sellers.isVerified, false));

  res.json({
    users:   userCount.count,
    sellers: sellerCount.count,
    orders:  orderCount.count,
    pendingVerifications: pendingSellers.count,
  });
});

// GET /v1/admin/sellers/pending
router.get('/sellers/pending', async (_req, res) => {
  const pending = await db.select().from(sellers)
    .where(eq(sellers.isVerified, false))
    .orderBy(desc(sellers.createdAt));
  res.json(pending);
});

// POST /v1/admin/sellers/:id/verify
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

  // Audit log
  await db.insert(auditLogs).values({
    adminId:    req.user!.userId,
    action:     approved ? 'seller_verified' : 'seller_rejected',
    targetType: 'seller',
    targetId:   seller.id,
    after:      { approved, reason },
  });

  res.json({ seller, message: approved ? 'Seller verified' : 'Seller rejected' });
});

// GET /v1/admin/orders?status=dispute
router.get('/orders', async (req, res) => {
  const { status, limit = 50 } = req.query as any;
  const where = status ? eq(orders.status, status) : undefined;
  const items = await db.select().from(orders)
    .where(where).orderBy(desc(orders.createdAt)).limit(Number(limit));
  res.json(items);
});

// PATCH /v1/admin/products/:id/moderate
router.patch('/products/:id/moderate', async (req, res) => {
  const { action } = z.object({ action: z.enum(['approve', 'reject']) }).parse(req.body);
  const [product] = await db.update(products)
    .set({ status: action === 'approve' ? 'active' : 'rejected', updatedAt: new Date() })
    .where(eq(products.id, String(req.params.id)))
    .returning();
  res.json(product);
});

export default router;
