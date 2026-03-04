import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { orders, orderItems, products, users, sellers } from '../db/schema';
import { authenticate, requireSeller, requireAdmin } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { eq, and, or } from 'drizzle-orm';
import { sendPushNotification } from '../services/push';

const router = Router();

const ORDER_STATUS_TRANSITIONS: Record<string, string[]> = {
  new:       ['confirmed', 'cancelled'],
  confirmed: ['packed', 'cancelled'],
  packed:    ['delivery', 'cancelled'],
  delivery:  ['delivered'],
  delivered: ['done', 'dispute'],
  done:      [],
  cancelled: [],
  dispute:   ['resolved_buyer', 'resolved_seller'],
};

// POST /v1/orders
router.post('/', authenticate, async (req, res) => {
  const body = z.object({
    items: z.array(z.object({
      productId: z.string().uuid(),
      variantId: z.string().uuid().optional(),
      quantity:  z.number().int().positive(),
    })).min(1),
    deliveryAddress: z.string().optional(),
    deliveryLat:     z.number().optional(),
    deliveryLng:     z.number().optional(),
    deliveryService: z.enum(['self', 'express24', 'yandex', 'gogoexpress']).default('self'),
    buyerNote:       z.string().max(500).optional(),
  }).parse(req.body);

  // Validate products and calculate total
  let totalTiyin = 0;
  const itemsData = [];
  let sellerId: string | null = null;

  for (const item of body.items) {
    const [product] = await db.select().from(products)
      .where(and(eq(products.id, item.productId), eq(products.status, 'active'))).limit(1);
    if (!product) throw new AppError(404, `Product ${item.productId} not found`);
    if (product.stock < item.quantity) throw new AppError(422, `Not enough stock for ${product.title}`);

    if (!sellerId) sellerId = product.sellerId;
    // For MVP: single seller per order
    if (product.sellerId !== sellerId) throw new AppError(400, 'All items must be from same seller');

    totalTiyin += product.priceTiyin * item.quantity;
    itemsData.push({ ...item, priceTiyin: product.priceTiyin, title: product.title });
  }

  const [order] = await db.insert(orders).values({
    buyerId:         req.user!.userId,
    sellerId:        sellerId!,
    totalTiyin,
    deliveryAddress: body.deliveryAddress,
    deliveryLat:     body.deliveryLat,
    deliveryLng:     body.deliveryLng,
    deliveryService: body.deliveryService,
    buyerNote:       body.buyerNote,
  }).returning();

  await db.insert(orderItems).values(
    itemsData.map(i => ({ orderId: order.id, ...i }))
  );

  // TODO: send push to seller
  res.status(201).json(order);
});

// GET /v1/orders
router.get('/', authenticate, async (req, res) => {
  const q = z.object({
    status: z.string().optional(),
    page:   z.coerce.number().default(1),
    limit:  z.coerce.number().max(50).default(20),
  }).parse(req.query);

  const userId  = req.user!.userId;
  const role    = req.user!.role;

  // For sellers — filter by their sellerId
  let ordersList;
  if (role === 'seller') {
    const [seller] = await db.select().from(sellers).where(eq(sellers.userId, userId)).limit(1);
    ordersList = await db.select().from(orders).where(
      and(eq(orders.sellerId, seller.id), q.status ? eq(orders.status, q.status as any) : undefined)
    ).limit(q.limit).offset((q.page - 1) * q.limit);
  } else {
    ordersList = await db.select().from(orders).where(
      and(eq(orders.buyerId, userId), q.status ? eq(orders.status, q.status as any) : undefined)
    ).limit(q.limit).offset((q.page - 1) * q.limit);
  }

  res.json({ items: ordersList, page: q.page, limit: q.limit });
});

// GET /v1/orders/:id
router.get('/:id', authenticate, async (req, res) => {
  const [order] = await db.select().from(orders).where(eq(orders.id, req.params.id)).limit(1);
  if (!order) throw new AppError(404, 'Order not found');

  const items = await db.select().from(orderItems).where(eq(orderItems.orderId, order.id));
  res.json({ ...order, items });
});

// PATCH /v1/orders/:id/status
router.patch('/:id/status', authenticate, async (req, res) => {
  const { status } = z.object({ status: z.string() }).parse(req.body);
  const [order] = await db.select().from(orders).where(eq(orders.id, req.params.id)).limit(1);
  if (!order) throw new AppError(404, 'Order not found');

  const allowed = ORDER_STATUS_TRANSITIONS[order.status] || [];
  if (!allowed.includes(status)) {
    throw new AppError(400, `Cannot transition from ${order.status} to ${status}`);
  }

  const [updated] = await db.update(orders)
    .set({
      status: status as any,
      updatedAt: new Date(),
      completedAt: status === 'done' ? new Date() : undefined,
    })
    .where(eq(orders.id, req.params.id))
    .returning();

  // Push notification to buyer
  const [buyer] = await db.select().from(users).where(eq(users.id, order.buyerId)).limit(1);
  if (buyer?.fcmToken) {
    sendPushNotification(buyer.fcmToken, {
      title: `Заказ ${order.id.slice(-6).toUpperCase()}`,
      body:  `Статус изменён: ${status}`,
    }).catch(() => {});
  }

  res.json(updated);
});

// POST /v1/orders/:id/dispute
router.post('/:id/dispute', authenticate, async (req, res) => {
  const { reason } = z.object({ reason: z.string().min(10) }).parse(req.body);
  const [order] = await db.select().from(orders).where(eq(orders.id, req.params.id)).limit(1);
  if (!order) throw new AppError(404, 'Order not found');

  await db.update(orders).set({ status: 'dispute', updatedAt: new Date() }).where(eq(orders.id, order.id));
  res.json({ message: 'Dispute opened', reason });
});

// POST /v1/orders/:id/review
router.post('/:id/review', authenticate, async (req, res) => {
  const body = z.object({
    rating: z.number().int().min(1).max(5),
    text:   z.string().max(1000).optional(),
  }).parse(req.body);

  const [order] = await db.select().from(orders)
    .where(and(eq(orders.id, req.params.id), eq(orders.buyerId, req.user!.userId))).limit(1);
  if (!order) throw new AppError(404, 'Order not found');
  if (order.status !== 'done') throw new AppError(422, 'Can only review completed orders');

  res.status(201).json({ message: 'Review saved', ...body });
});

export default router;
