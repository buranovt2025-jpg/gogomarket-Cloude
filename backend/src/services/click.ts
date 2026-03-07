/**
 * Click UZ Payment Integration
 * Docs: https://docs.click.uz/
 */
import crypto from 'crypto';
import { db } from '../db';
import { payments, orders } from '../db/schema';
import { eq } from 'drizzle-orm';
import { logger } from '../utils/logger';

const SERVICE_ID  = process.env.CLICK_SERVICE_ID!;
const MERCHANT_ID = process.env.CLICK_MERCHANT_ID!;
const SECRET_KEY  = process.env.CLICK_SECRET_KEY!;

// ── Generate payment URL ──────────────────────────────────────────────────────
export function getClickPayUrl(params: {
  orderId: string;
  amountUzs: number;   // в сумах (не тийинах)
  returnUrl?: string;
}): string {
  const amount = params.amountUzs.toFixed(2);
  const url = new URL('https://my.click.uz/services/pay');
  url.searchParams.set('service_id',  SERVICE_ID);
  url.searchParams.set('merchant_id', MERCHANT_ID);
  url.searchParams.set('amount',      amount);
  url.searchParams.set('transaction_param', params.orderId);
  url.searchParams.set('return_url',  params.returnUrl ?? 'gogomarket://payment');
  return url.toString();
}

// ── Verify Click signature ────────────────────────────────────────────────────
function verifyClickSign(body: Record<string, string>): boolean {
  const {
    click_trans_id, service_id, click_paydoc_id,
    merchant_trans_id, amount, action, sign_time, sign_string,
  } = body;

  const mySign = crypto
    .createHash('md5')
    .update(
      `${click_trans_id}${service_id}${SECRET_KEY}${merchant_trans_id}${amount}${action}${sign_time}`
    )
    .digest('hex');

  return mySign === sign_string;
}

// ── PREPARE handler (action=0) ────────────────────────────────────────────────
export async function clickPrepare(body: Record<string, string>) {
  if (!verifyClickSign(body)) {
    return { error: -1, error_note: 'SIGN CHECK FAILED' };
  }

  const orderId = body.merchant_trans_id;
  const [order] = await db.select().from(orders).where(eq(orders.id, orderId)).limit(1);

  if (!order) return { error: -5, error_note: 'ORDER NOT FOUND' };
  if (order.status === 'cancelled') return { error: -9, error_note: 'ORDER CANCELLED' };

  // Already paid?
  const [existing] = await db.select().from(payments)
    .where(eq(payments.orderId, orderId)).limit(1);
  if (existing?.status === 'paid') return { error: -4, error_note: 'ALREADY PAID' };

  // Create or update payment record
  if (!existing) {
    await db.insert(payments).values({
      orderId,
      provider:    'click',
      amountTiyin: Math.round(parseFloat(body.amount) * 100),
      status:      'pending',
      externalId:  body.click_trans_id,
    });
  }

  return {
    click_trans_id:   body.click_trans_id,
    merchant_trans_id: orderId,
    merchant_prepare_id: orderId,
    error: 0,
    error_note: 'Success',
  };
}

// ── COMPLETE handler (action=1) ───────────────────────────────────────────────
export async function clickComplete(body: Record<string, string>) {
  if (!verifyClickSign(body)) {
    return { error: -1, error_note: 'SIGN CHECK FAILED' };
  }

  const orderId = body.merchant_trans_id;
  const clickError = parseInt(body.error ?? '0');

  if (clickError < 0) {
    // Click отменил платёж
    await db.update(payments)
      .set({ status: 'failed', externalMeta: body as any })
      .where(eq(payments.orderId, orderId));
    logger.warn({ orderId }, 'Click payment cancelled by provider');
    return { error: 0, error_note: 'Success' };
  }

  // Успешная оплата
  await db.update(payments).set({
    status:       'paid',
    externalId:   body.click_trans_id,
    externalMeta: body as any,
    paidAt:       new Date(),
  }).where(eq(payments.orderId, orderId));

  await db.update(orders).set({
    status:    'confirmed',
    updatedAt: new Date(),
  }).where(eq(orders.id, orderId));

  logger.info({ orderId }, 'Click payment confirmed ✅');

  return {
    click_trans_id:    body.click_trans_id,
    merchant_trans_id: orderId,
    merchant_confirm_id: orderId,
    error: 0,
    error_note: 'Success',
  };
}
