import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { products, productPhotos, sellers, listingExpirations } from '../db/schema';
import { authenticate, requireSeller } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { eq, and, gte, lte, ilike, desc, asc, isNull, count, sql } from 'drizzle-orm';

const router = Router();

// GET /v1/products — public, with filters
router.get('/', async (req, res) => {
  const q = z.object({
    page:      z.coerce.number().min(1).default(1),
    limit:     z.coerce.number().min(1).max(50).default(20),
    category:  z.string().uuid().optional(),
    seller_id: z.string().uuid().optional(),
    q:         z.string().max(100).optional(),
    price_min: z.coerce.number().optional(),
    price_max: z.coerce.number().optional(),
    sort:      z.enum(['popular', 'new', 'price_asc', 'price_desc', 'rating']).default('popular'),
  }).parse(req.query);

  const where = [
    eq(products.status, 'active'),
    isNull(products.deletedAt),
    q.category  ? eq(products.categoryId,  q.category)  : undefined,
    q.seller_id ? eq(products.sellerId,   q.seller_id) : undefined,
    q.q         ? ilike(products.title,   `%${q.q}%`)  : undefined,
    q.price_min ? gte(products.priceTiyin, q.price_min * 100) : undefined,
    q.price_max ? lte(products.priceTiyin, q.price_max * 100) : undefined,
  ].filter(Boolean) as any[];

  const sortMap: Record<string, any> = {
    popular:    desc(products.saleCount),
    new:        desc(products.createdAt),
    price_asc:  asc(products.priceTiyin),
    price_desc: desc(products.priceTiyin),
    rating:     desc(products.avgRating),
  };

  const items = await db.select().from(products)
    .where(and(...where))
    .orderBy(sortMap[q.sort])
    .limit(q.limit)
    .offset((q.page - 1) * q.limit);

  res.json({ items, page: q.page, limit: q.limit });
});

// GET /v1/products/:id — public
router.get('/:id', async (req, res) => {
  const [product] = await db.select().from(products)
    .where(and(eq(products.id, String(req.params.id)), isNull(products.deletedAt)))
    .limit(1);
  if (!product) throw new AppError(404, 'Product not found');

  const photos = await db.select().from(productPhotos)
    .where(eq(productPhotos.productId, product.id))
    .orderBy(asc(productPhotos.order));

  // Increment view count (async, no await)
  db.update(products)
    .set({ viewCount: (product.viewCount || 0) + 1 })
    .where(eq(products.id, product.id))
    .catch(() => {});

  res.json({ ...product, photos });
});

// POST /v1/products — tier 2+ only
router.post('/', authenticate, requireSeller, async (req, res) => {
  const body = z.object({
    title:        z.string().min(3).max(200),
    description:  z.string().max(2000).optional(),
    categoryId:   z.string().uuid().optional(),
    priceTiyin:   z.number().int().positive(),
    oldPriceTiyin: z.number().int().positive().optional(),
    stock:        z.number().int().min(0),
    condition:    z.enum(['new', 'used']).default('new'),
    deliveryType: z.enum(['self', 'courier', 'both']).default('self'),
    tags:         z.array(z.string()).max(10).optional(),
    status:       z.enum(['draft', 'active']).default('draft'),
  }).parse(req.body);

  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller) throw new AppError(403, 'Seller profile not found');

  const userTier = req.user!.tier ?? 1;
  let expiresAt: Date | null = null;

  // Tier 2: enforce 10 products/week limit + auto-expiry
  if (userTier === 2) {
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const [{ weeklyCount }] = await db.select({
      weeklyCount: count(),
    }).from(products).where(
      and(
        eq(products.sellerId, seller.id),
        gte(products.createdAt, weekAgo),
        isNull(products.deletedAt),
      )
    );

    if (weeklyCount >= 10) {
      throw new AppError(429, 'Weekly limit reached: 10 products per week for private sellers.');
    }

    expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
  }

  const [product] = await db.insert(products)
    .values({ ...body, sellerId: seller.id, expiresAt })
    .returning();

  // Track expiry for tier 2
  if (expiresAt) {
    await db.insert(listingExpirations).values({
      listingType: 'product',
      listingId:   product.id,
      userId:      req.user!.userId,
      expiresAt,
    });
  }

  res.status(201).json(product);
});

// PATCH /v1/products/:id — owner only
router.patch('/:id', authenticate, requireSeller, async (req, res) => {
  const [existing] = await db.select().from(products)
    .where(and(eq(products.id, String(req.params.id)), isNull(products.deletedAt))).limit(1);

  if (!existing) throw new AppError(404, 'Product not found');

  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller || existing.sellerId !== seller.id) {
    throw new AppError(403, 'Not your product');
  }

  const updates = z.object({
    title:        z.string().min(3).max(200).optional(),
    description:  z.string().optional(),
    priceTiyin:   z.number().positive().optional(),
    oldPriceTiyin: z.number().positive().optional(),
    stock:        z.number().min(0).optional(),
    status:       z.enum(['draft', 'active', 'out_of_stock']).optional(),
    tags:         z.array(z.string()).optional(),
  }).parse(req.body);

  const [updated] = await db.update(products)
    .set({ ...updates, updatedAt: new Date() })
    .where(eq(products.id, String(req.params.id)))
    .returning();

  res.json(updated);
});

// DELETE /v1/products/:id — soft delete
router.delete('/:id', authenticate, requireSeller, async (req, res) => {
  await db.update(products)
    .set({ deletedAt: new Date(), status: 'deleted' })
    .where(eq(products.id, String(req.params.id)));
  res.json({ message: 'Product deleted' });
});

// POST /v1/products/:id/photos — attach photos to product
import multer from 'multer';
import path from 'path';
import fs from 'fs';

const UPLOAD_DIR = process.env.UPLOAD_DIR || '/opt/gogomarket-Cloude/uploads';
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const photoUpload = multer({
  storage: multer.diskStorage({
    destination: (_, __, cb) => cb(null, UPLOAD_DIR),
    filename: (_, file, cb) => {
      const ext  = path.extname(file.originalname).toLowerCase();
      const name = `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`;
      cb(null, name);
    },
  }),
  limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
  fileFilter: (_, file, cb) => {
    const ok = ['image/jpeg','image/png','image/webp'].includes(file.mimetype);
    cb(null, ok);
  },
});

router.post('/:id/photos', authenticate, requireSeller, photoUpload.array('photos', 10), async (req, res) => {
  const files = req.files as Express.Multer.File[];
  if (!files?.length) throw new AppError(400, 'No photos uploaded');

  const [existing] = await db.select().from(products)
    .where(and(eq(products.id, String(req.params.id)), isNull(products.deletedAt))).limit(1);
  if (!existing) throw new AppError(404, 'Product not found');

  const [seller] = await db.select().from(sellers)
    .where(eq(sellers.userId, req.user!.userId)).limit(1);
  if (!seller || existing.sellerId !== seller.id) throw new AppError(403, 'Not your product');

  const baseUrl = process.env.CDN_URL || 'http://206.189.12.56';

  // Get current max order
  const existingPhotos = await db.select().from(productPhotos)
    .where(eq(productPhotos.productId, existing.id));
  let order = existingPhotos.length;

  const inserted = await Promise.all(files.map(file =>
    db.insert(productPhotos).values({
      productId: existing.id,
      url:       `${baseUrl}/uploads/${file.filename}`,
      isMain:    order === 0,
      order:     order++,
    }).returning()
  ));

  res.status(201).json({ photos: inserted.map(r => r[0]) });
});

// DELETE /v1/products/:id/photos/:photoId
router.delete('/:id/photos/:photoId', authenticate, requireSeller, async (req, res) => {
  const [photo] = await db.select().from(productPhotos)
    .where(eq(productPhotos.id, String(req.params.photoId))).limit(1);
  if (!photo) throw new AppError(404, 'Photo not found');

  // Delete file from disk
  const filename = photo.url.split('/uploads/').pop();
  if (filename) {
    const filepath = path.join(UPLOAD_DIR, filename);
    if (fs.existsSync(filepath)) fs.unlinkSync(filepath);
  }

  await db.delete(productPhotos).where(eq(productPhotos.id, photo.id));
  res.json({ message: 'Photo deleted' });
});

export default router;
