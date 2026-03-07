import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { payments, orders } from '../db/schema';
import { authenticate } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { eq } from 'drizzle-orm';
import { getClickPayUrl, clickPrepare, clickComplete } from '../services/click';
import { getPaymeUrl, verifyPaymeAuth, handlePaymeRpc } from '../services/payme';
import { logger } from '../utils/logger';

const router = Router();

// ── GET /v1/payments/initiate ─────────────────────────────────────────────────
// Покупатель выбирает провайдера, получает URL для оплаты
router.post('/initiate', authenticate, async (req, res) => {
  const { orderId, provider } = z.object({
    orderId:  z.string().uuid(),
    provider: z.enum(['click', 'payme']),
  }).parse(req.body);

  const [order] = await db.select().from(orders)
    .where(eq(orders.id, orderId)).limit(1);
  if (!order) throw new AppError(404, 'Order not found');
  if (order.buyerId !== req.user!.userId) throw new AppError(403, 'Not your order');
  if (order.status === 'cancelled') throw new AppError(400, 'Order is cancelled');

  // Check not already paid
  const [existingPay] = await db.select().from(payments)
    .where(eq(payments.orderId, orderId)).limit(1);
  if (existingPay?.status === 'paid') throw new AppError(400, 'Already paid');

  const amountUzs    = order.totalTiyin / 100;
  const amountTiyin  = order.totalTiyin;

  let payUrl: string;
  if (provider === 'click') {
    payUrl = getClickPayUrl({ orderId, amountUzs });
  } else {
    payUrl = getPaymeUrl({ orderId, amountTiyin });
  }

  res.json({ payUrl, provider, amountTiyin, amountUzs });
});

// ── GET /v1/payments/status/:orderId ─────────────────────────────────────────
router.get('/status/:orderId', authenticate, async (req, res) => {
  const [payment] = await db.select().from(payments)
    .where(eq(payments.orderId, req.params.orderId)).limit(1);
  if (!payment) return res.json({ status: 'not_initiated' });
  res.json({ status: payment.status, provider: payment.provider, paidAt: payment.paidAt });
});

// ── POST /v1/payments/click ───────────────────────────────────────────────────
// Click webhook — PREPARE (action=0) и COMPLETE (action=1)
router.post('/click', async (req, res) => {
  const body = req.body as Record<string, string>;
  const action = parseInt(body.action ?? '-1');
  logger.info({ action, orderId: body.merchant_trans_id }, 'Click webhook');

  let result: any;
  if (action === 0) {
    result = await clickPrepare(body);
  } else if (action === 1) {
    result = await clickComplete(body);
  } else {
    result = { error: -2, error_note: 'Invalid action' };
  }

  res.json(result);
});

// ── POST /v1/payments/payme ───────────────────────────────────────────────────
// Payme webhook — JSON-RPC 2.0
router.post('/payme', async (req, res) => {
  if (!verifyPaymeAuth(req.headers.authorization)) {
    return res.status(401).json({
      error: { code: -32504, message: { ru: 'Ошибка авторизации', en: 'Unauthorized' } },
    });
  }

  const { id: rpcId, method, params } = req.body;
  logger.info({ method, params }, 'Payme RPC');

  const result = await handlePaymeRpc(method, params);
  res.json({ jsonrpc: '2.0', id: rpcId, ...result });
});

export default router;
