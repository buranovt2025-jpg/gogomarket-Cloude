/**
 * Payme (Paycom) Integration — JSON-RPC 2.0
 * Docs: https://developer.help.paycom.uz/
 */
import crypto from 'crypto';
import { db } from '../db';
import { payments, orders } from '../db/schema';
import { eq } from 'drizzle-orm';
import { logger } from '../utils/logger';

const MERCHANT_ID  = process.env.PAYME_MERCHANT_ID!;
const SECRET_KEY   = process.env.PAYME_SECRET_KEY!;
const TEST_SECRET  = process.env.PAYME_TEST_SECRET!;

const isTest = process.env.NODE_ENV !== 'production';
const secret = isTest ? TEST_SECRET : SECRET_KEY;

// ── Generate payment URL ──────────────────────────────────────────────────────
export function getPaymeUrl(params: {
  orderId: string;
  amountTiyin: number;  // в тийинах!
  returnUrl?: string;
}): string {
  // Payme encodes params as base64
  const payload = JSON.stringify({
    m:  MERCHANT_ID,
    ac: { order_id: params.orderId },
    a:  params.amountTiyin,
    c:  params.returnUrl ?? 'gogomarket://payment',
  });
  const encoded = Buffer.from(payload).toString('base64');
  const host = isTest ? 'test.paycom.uz' : 'checkout.paycom.uz';
  return `https://${host}/${encoded}`;
}

// ── Verify Basic Auth ─────────────────────────────────────────────────────────
export function verifyPaymeAuth(authHeader: string | undefined): boolean {
  if (!authHeader?.startsWith('Basic ')) return false;
  const encoded = authHeader.slice(6);
  const decoded = Buffer.from(encoded, 'base64').toString('utf8');
  // Format: "Paycom:<secret>"
  const [, providedSecret] = decoded.split(':');
  return providedSecret === secret;
}

// ── RPC Method handlers ───────────────────────────────────────────────────────
type RpcResult = { result?: any; error?: { code: number; message: any } };

export async function handlePaymeRpc(method: string, params: any): Promise<RpcResult> {
  switch (method) {
    case 'CheckPerformTransaction': return checkPerformTransaction(params);
    case 'CreateTransaction':       return createTransaction(params);
    case 'PerformTransaction':      return performTransaction(params);
    case 'CancelTransaction':       return cancelTransaction(params);
    case 'CheckTransaction':        return checkTransaction(params);
    case 'GetStatement':            return getStatement(params);
    default:
      return { error: { code: -32601, message: { ru: 'Метод не найден', uz: 'Metod topilmadi', en: 'Method not found' } } };
  }
}

async function checkPerformTransaction(params: any): Promise<RpcResult> {
  const orderId = params?.account?.order_id;
  if (!orderId) return { error: { code: -31050, message: { ru: 'Заказ не найден', uz: 'Buyurtma topilmadi', en: 'Order not found' } } };

  const [order] = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
  if (!order) return { error: { code: -31050, message: { ru: 'Заказ не найден', uz: 'Buyurtma topilmadi', en: 'Order not found' } } };
  if (order.status === 'cancelled') return { error: { code: -31050, message: { ru: 'Заказ отменён', uz: 'Buyurtma bekor qilindi', en: 'Order cancelled' } } };

  // Validate amount
  if (params.amount !== order.totalTiyin) {
    return { error: { code: -31001, message: { ru: 'Неверная сумма', uz: 'Noto\'g\'ri summa', en: 'Wrong amount' } } };
  }

  return { result: { allow: true } };
}

async function createTransaction(params: any): Promise<RpcResult> {
  const orderId = params?.account?.order_id;
  const txId = params.id;
  const now = Date.now();

  // Check if transaction already exists
  const [existing] = await db.select().from(payments)
    .where(eq(payments.externalId, txId)).limit(1);

  if (existing) {
    if (existing.status === 'failed') {
      return { error: { code: -31008, message: { ru: 'Транзакция отменена', en: 'Transaction cancelled' } } };
    }
    return { result: { create_time: existing.createdAt.getTime(), transaction: existing.id, state: 1 } };
  }

  const [order] = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);
  if (!order) return { error: { code: -31050, message: { ru: 'Заказ не найден', en: 'Order not found' } } };

  const [payment] = await db.insert(payments).values({
    orderId,
    provider:    'payme',
    amountTiyin: params.amount,
    status:      'pending',
    externalId:  txId,
    externalMeta: params,
  }).returning();

  return { result: { create_time: now, transaction: payment.id, state: 1 } };
}

async function performTransaction(params: any): Promise<RpcResult> {
  const txId = params.id;
  const now = Date.now();

  const [payment] = await db.select().from(payments)
    .where(eq(payments.externalId, txId)).limit(1);

  if (!payment) return { error: { code: -31003, message: { ru: 'Транзакция не найдена', en: 'Transaction not found' } } };
  if (payment.status === 'paid') {
    return { result: { perform_time: payment.paidAt?.getTime() ?? now, transaction: payment.id, state: 2 } };
  }
  if (payment.status === 'failed') {
    return { error: { code: -31008, message: { ru: 'Транзакция отменена', en: 'Transaction cancelled' } } };
  }

  // Подтверждаем оплату
  await db.update(payments).set({
    status: 'paid', paidAt: new Date(), externalMeta: params,
  }).where(eq(payments.externalId, txId));

  await db.update(orders).set({
    status: 'confirmed', updatedAt: new Date(),
  }).where(eq(orders.id, payment.orderId));

  logger.info({ orderId: payment.orderId }, 'Payme payment confirmed ✅');

  return { result: { perform_time: now, transaction: payment.id, state: 2 } };
}

async function cancelTransaction(params: any): Promise<RpcResult> {
  const txId = params.id;
  const now = Date.now();

  const [payment] = await db.select().from(payments)
    .where(eq(payments.externalId, txId)).limit(1);

  if (!payment) return { error: { code: -31003, message: { ru: 'Транзакция не найдена', en: 'Transaction not found' } } };
  if (payment.status === 'paid') {
    return { error: { code: -31007, message: { ru: 'Нельзя отменить выполненную транзакцию', en: 'Cannot cancel performed transaction' } } };
  }

  await db.update(payments).set({
    status: 'failed', externalMeta: params,
  }).where(eq(payments.externalId, txId));

  return { result: { cancel_time: now, transaction: payment.id, state: -1 } };
}

async function checkTransaction(params: any): Promise<RpcResult> {
  const [payment] = await db.select().from(payments)
    .where(eq(payments.externalId, params.id)).limit(1);

  if (!payment) return { error: { code: -31003, message: { ru: 'Транзакция не найдена', en: 'Transaction not found' } } };

  const stateMap: Record<string, number> = { pending: 1, paid: 2, failed: -1 };
  return {
    result: {
      create_time:  payment.createdAt.getTime(),
      perform_time: payment.paidAt?.getTime() ?? 0,
      cancel_time:  0,
      transaction:  payment.id,
      state:        stateMap[payment.status] ?? 1,
      reason:       null,
    },
  };
}

async function getStatement(params: any): Promise<RpcResult> {
  // Returns all transactions in time range
  const from = new Date(params.from);
  const to   = new Date(params.to);
  const txs  = await db.select().from(payments)
    .where(eq(payments.provider, 'payme'));

  const stateMap: Record<string, number> = { pending: 1, paid: 2, failed: -1 };

  return {
    result: {
      transactions: txs
        .filter(p => p.createdAt >= from && p.createdAt <= to)
        .map(p => ({
          id:           p.externalId,
          time:         p.createdAt.getTime(),
          amount:       p.amountTiyin,
          account:      { order_id: p.orderId },
          create_time:  p.createdAt.getTime(),
          perform_time: p.paidAt?.getTime() ?? 0,
          cancel_time:  0,
          transaction:  p.id,
          state:        stateMap[p.status] ?? 1,
          reason:       null,
        })),
    },
  };
}
