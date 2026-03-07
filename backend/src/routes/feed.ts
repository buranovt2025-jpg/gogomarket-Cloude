import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { products, productPhotos, sellers, reels } from '../db/schema';
import { eq, desc, and, isNull, sql, asc } from 'drizzle-orm';

const router = Router();

// GET /v1/feed — главная лента (товары + рилсы вперемешку)
router.get('/', async (req, res) => {
  const q = z.object({
    cursor:  z.coerce.number().default(0),
    limit:   z.coerce.number().max(30).default(20),
    cat:     z.string().optional(),
    type:    z.enum(['all', 'products', 'reels']).default('all'),
  }).parse(req.query);

  const where = and(
    eq(products.status, 'active'),
    isNull(products.deletedAt),
    q.cat ? eq(products.categoryId, q.cat) : undefined,
  );

  // Products with seller info and first photo
  const productItems = await db.select({
    id:           products.id,
    type:         sql<string>`'product'`,
    title:        products.title,
    description:  products.description,
    priceTiyin:   products.priceTiyin,
    oldPriceTiyin: products.oldPriceTiyin,
    saleCount:    products.saleCount,
    viewCount:    products.viewCount,
    avgRating:    products.avgRating,
    reviewCount:  products.reviewCount,
    isBoosted:    products.isBoosted,
    sellerId:     sellers.id,
    sellerName:   sellers.shopName,
    sellerAvatar: sellers.avatarUrl,
    sellerRating: sellers.avgRating,
    createdAt:    products.createdAt,
  })
  .from(products)
  .leftJoin(sellers, eq(products.sellerId, sellers.id))
  .where(where)
  .orderBy(desc(products.isBoosted), desc(products.createdAt))
  .limit(q.limit)
  .offset(q.cursor);

  // Fetch first photo for each product
  const productIds = productItems.map(p => p.id);
  const photos = productIds.length > 0
    ? await db.select()
        .from(productPhotos)
        .where(and(
          sql`${productPhotos.productId} = ANY(ARRAY[${sql.join(productIds.map(id => sql`${id}`), sql`, `)}])`,
          eq(productPhotos.isCover, true),
        ))
        .orderBy(asc(productPhotos.order))
    : [];

  // Map photos to products
  const photoMap = new Map<string, string>();
  for (const p of photos) {
    if (!photoMap.has(p.productId)) photoMap.set(p.productId, p.url);
  }

  // If no cover photos, get any photo per product
  if (photos.length === 0 && productIds.length > 0) {
    const anyPhotos = await db.select()
      .from(productPhotos)
      .where(sql`${productPhotos.productId} = ANY(ARRAY[${sql.join(productIds.map(id => sql`${id}`), sql`, `)}])`)
      .orderBy(asc(productPhotos.order));
    for (const p of anyPhotos) {
      if (!photoMap.has(p.productId)) photoMap.set(p.productId, p.url);
    }
  }

  const enrichedProducts = productItems.map(p => ({
    ...p,
    coverPhoto: photoMap.get(p.id) ?? null,
    photos:     photoMap.has(p.id) ? [photoMap.get(p.id)!] : [],
  }));

  // Reels (if type = all or reels)
  let reelItems: any[] = [];
  if (q.type !== 'products') {
    reelItems = await db.select({
      id:          reels.id,
      type:        sql<string>`'reel'`,
      title:       reels.title,
      videoUrl:    reels.videoUrl,
      coverUrl:    reels.thumbUrl,
      likeCount:   reels.likeCount,
      // commentCount: reels.commentCount,
      viewCount:   reels.viewCount,
      productId:   reels.productId,
      sellerId:    sellers.id,
      sellerName:  sellers.shopName,
      sellerAvatar: sellers.avatarUrl,
      createdAt:   reels.createdAt,
    })
    .from(reels)
    .leftJoin(sellers, eq(reels.sellerId, sellers.id))
    .where(eq(reels.status, 'active'))
    .orderBy(desc(reels.viewCount))
    .limit(10);
  }

  // Interleave: every 5 products → 1 reel
  const feed: any[] = [];
  let ri = 0;
  for (let i = 0; i < enrichedProducts.length; i++) {
    feed.push(enrichedProducts[i]);
    if ((i + 1) % 5 === 0 && ri < reelItems.length) {
      feed.push(reelItems[ri++]);
    }
  }

  const nextCursor = q.cursor + productItems.length;

  res.json({
    items:      feed,
    nextCursor: productItems.length === q.limit ? nextCursor : null,
    total:      enrichedProducts.length + reelItems.length,
  });
});

export default router;
