/**
 * Auto-expire job for tier-2 listings.
 * Runs every hour via setInterval.
 * - Deletes products and reels that have passed expiresAt
 * - Sends "3 days left" push notifications
 */
import { db } from '../db';
import { products, reels, listingExpirations, notifications } from '../db/schema';
import { eq, and, lte, isNull, sql } from 'drizzle-orm';

const THREE_DAYS_MS = 3 * 24 * 60 * 60 * 1000;
const HOUR_MS = 60 * 60 * 1000;

async function expireListings() {
  const now = new Date();
  console.log(`[autoExpire] Running at ${now.toISOString()}`);

  // ── 1. Delete expired products ──────────────────────────────
  const expiredProducts = await db
    .select({ listingId: listingExpirations.listingId, userId: listingExpirations.userId, id: listingExpirations.id })
    .from(listingExpirations)
    .where(
      and(
        eq(listingExpirations.listingType, 'product'),
        lte(listingExpirations.expiresAt, now),
        isNull(listingExpirations.deletedAt),
      )
    );

  for (const exp of expiredProducts) {
    await db.update(products)
      .set({ deletedAt: now, status: 'deleted' })
      .where(eq(products.id, exp.listingId));

    await db.update(listingExpirations)
      .set({ deletedAt: now })
      .where(eq(listingExpirations.id, exp.id));

    console.log(`[autoExpire] Deleted product ${exp.listingId}`);
  }

  // ── 2. Delete expired reels ─────────────────────────────────
  const expiredReels = await db
    .select({ listingId: listingExpirations.listingId, userId: listingExpirations.userId, id: listingExpirations.id })
    .from(listingExpirations)
    .where(
      and(
        eq(listingExpirations.listingType, 'reel'),
        lte(listingExpirations.expiresAt, now),
        isNull(listingExpirations.deletedAt),
      )
    );

  for (const exp of expiredReels) {
    await db.update(reels)
      .set({ deletedAt: now, status: 'deleted' } as any)
      .where(eq(reels.id, exp.listingId));

    await db.update(listingExpirations)
      .set({ deletedAt: now })
      .where(eq(listingExpirations.id, exp.id));

    console.log(`[autoExpire] Deleted reel ${exp.listingId}`);
  }

  // ── 3. Send "3 days left" notifications ─────────────────────
  const notifyBefore = new Date(now.getTime() + THREE_DAYS_MS);

  const soonExpiring = await db
    .select()
    .from(listingExpirations)
    .where(
      and(
        lte(listingExpirations.expiresAt, notifyBefore),
        isNull(listingExpirations.notifiedAt),
        isNull(listingExpirations.deletedAt),
      )
    );

  for (const exp of soonExpiring) {
    const daysLeft = Math.ceil((exp.expiresAt.getTime() - now.getTime()) / (24 * 60 * 60 * 1000));
    if (daysLeft <= 0) continue;

    const typeLabel = exp.listingType === 'product' ? 'товар' : 'рилс';

    await db.insert(notifications).values({
      userId:   exp.userId,
      type:     'system',
      title:    `Ваш ${typeLabel} истекает через ${daysLeft} д.`,
      body:     `Продлите объявление, чтобы оно не удалилось автоматически.`,
      meta:     { listingType: exp.listingType, listingId: exp.listingId },
    });

    await db.update(listingExpirations)
      .set({ notifiedAt: now })
      .where(eq(listingExpirations.id, exp.id));

    console.log(`[autoExpire] Notified user ${exp.userId} for ${exp.listingType} ${exp.listingId}`);
  }
}

export function startAutoExpireJob() {
  console.log('[autoExpire] Starting auto-expire job (runs every hour)');
  // Run immediately on startup, then every hour
  expireListings().catch(e => console.error('[autoExpire] Error:', e));
  setInterval(() => {
    expireListings().catch(e => console.error('[autoExpire] Error:', e));
  }, HOUR_MS);
}
