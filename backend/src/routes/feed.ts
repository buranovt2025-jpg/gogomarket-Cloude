import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { products, sellers, users } from '../db/schema';
import { eq, desc, and, isNull, sql } from 'drizzle-orm';

const router = Router();

// GET /v1/feed
router.get('/', async (req, res) => {
  const q = z.object({
    mode:  z.enum(['discover', 'following']).default('discover'),
    page:  z.coerce.number().default(1),
    limit: z.coerce.number().max(50).default(20),
    cat:   z.string().optional(),
  }).parse(req.query);

  const offset = (q.page - 1) * q.limit;

  const where = and(
    eq(products.status, 'active'),
    isNull(products.deletedAt),
    q.cat ? eq(products.categoryId, q.cat) : undefined,
  );

  const [items, [{ count }]] = await Promise.all([
    db.select().from(products)
      .where(where)
      .orderBy(desc(products.isBoosted), desc(products.createdAt))
      .limit(q.limit)
      .offset(offset),
    db.select({ count: sql<number>`count(*)::int` }).from(products).where(where),
  ]);

  res.json({ items, total: count, page: q.page, limit: q.limit });
});

export default router;
