/**
 * GogoMarket Seed Script
 * Run on server: cd /opt/gogomarket-Cloude/backend && npx ts-node scripts/seed.ts
 */
import { db } from '../src/db';
import { users, sellers, categories, products, productPhotos, reels } from '../src/db/schema';
import { eq } from 'drizzle-orm';

async function seed() {
  console.log('🌱 Seeding GogoMarket...\n');

  // ── Categories ────────────────────────────────────────────────────────────
  await db.insert(categories).values([
    { name: 'Одежда',  slug: 'clothes', icon: '👗', sortOrder: 1 },
    { name: 'Обувь',   slug: 'shoes',   icon: '👟', sortOrder: 2 },
    { name: 'Красота', slug: 'beauty',  icon: '💄', sortOrder: 3 },
    { name: 'Техника', slug: 'tech',    icon: '📱', sortOrder: 4 },
    { name: 'Дом',     slug: 'home',    icon: '🏠', sortOrder: 5 },
    { name: 'Спорт',   slug: 'sport',   icon: '🏋️', sortOrder: 6 },
  ]).onConflictDoNothing();

  const allCats = await db.select().from(categories);
  const catMap: Record<string, string> = {};
  for (const c of allCats) catMap[c.slug] = c.id;
  console.log('✓ Categories:', Object.keys(catMap));

  // ── Seller users ──────────────────────────────────────────────────────────
  const sellerInputs = [
    { phone: '+998901111111', name: 'Aisha Karimova',    role: 'seller' as const },
    { phone: '+998902222222', name: 'Kamola Yusupova',   role: 'seller' as const },
    { phone: '+998903333333', name: 'Sardor Toshmatov',  role: 'seller' as const },
    { phone: '+998904444444', name: 'Dilnoza Ergasheva', role: 'seller' as const },
    { phone: '+998905555555', name: 'Bobur Aliyev',      role: 'seller' as const },
  ];

  const userIds: string[] = [];
  for (const u of sellerInputs) {
    let [row] = await db.select().from(users).where(eq(users.phone, u.phone));
    if (!row) {
      [row] = await db.insert(users).values({ ...u, isVerified: true }).returning();
    }
    userIds.push(row.id);
  }
  console.log('✓ Users:', userIds.length);

  // ── Sellers ───────────────────────────────────────────────────────────────
  const sellerInputs2 = [
    { userId: userIds[0], shopName: 'Aisha Fashion',
      description: 'Трендовая женская одежда. Новые коллекции каждую неделю 🌸',
      logoUrl: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=200&q=80',
      avgRating: 4.8, reviewCount: 234, followerCount: 12400 },
    { userId: userIds[1], shopName: 'Kamola Beauty',
      description: 'Корейская косметика и уходовые средства 💄',
      logoUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200&q=80',
      avgRating: 4.9, reviewCount: 567, followerCount: 28900 },
    { userId: userIds[2], shopName: 'TechZone UZ',
      description: 'Гаджеты, электроника, аксессуары 📱',
      logoUrl: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=200&q=80',
      avgRating: 4.7, reviewCount: 189, followerCount: 8700 },
    { userId: userIds[3], shopName: 'Home Comfort',
      description: 'Мебель и декор для уютного дома 🏠',
      logoUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
      avgRating: 4.6, reviewCount: 98, followerCount: 5300 },
    { userId: userIds[4], shopName: 'Sport Life',
      description: 'Спортивная одежда и инвентарь 💪',
      logoUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&q=80',
      avgRating: 4.8, reviewCount: 312, followerCount: 15600 },
  ];

  const sellerIds: string[] = [];
  for (const s of sellerInputs2) {
    let [row] = await db.select().from(sellers).where(eq(sellers.userId, s.userId));
    if (!row) {
      [row] = await db.insert(sellers).values({ ...s, plan: 'business', isVerified: true }).returning();
    }
    sellerIds.push(row.id);
  }
  const [aishaId, kamolaId, techId, homeId, sportId] = sellerIds;
  console.log('✓ Sellers:', sellerIds.length);

  // ── Products ──────────────────────────────────────────────────────────────
  type PInput = { sellerId: string; categoryId: string; title: string;
    priceTiyin: number; oldPriceTiyin?: number; saleCount: number; viewCount: number;
    photos: string[]; isBoosted?: boolean; };

  const productInputs: PInput[] = [
    // Aisha Fashion
    { sellerId: aishaId, categoryId: catMap['clothes'],
      title: 'Платье летнее с цветочным принтом',
      priceTiyin: 18500000, oldPriceTiyin: 25000000, saleCount: 145, viewCount: 3200, isBoosted: true,
      photos: ['https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
               'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600&q=80'] },
    { sellerId: aishaId, categoryId: catMap['clothes'],
      title: 'Пальто оверсайз бежевое',
      priceTiyin: 68000000, oldPriceTiyin: 85000000, saleCount: 89, viewCount: 5600,
      photos: ['https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80',
               'https://images.unsplash.com/photo-1539533018257-f91e2d0d1cbc?w=600&q=80'] },
    { sellerId: aishaId, categoryId: catMap['clothes'],
      title: 'Джинсы mom fit голубые',
      priceTiyin: 21000000, saleCount: 234, viewCount: 8900,
      photos: ['https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80'] },
    { sellerId: aishaId, categoryId: catMap['clothes'],
      title: 'Блузка шёлковая белая',
      priceTiyin: 32000000, oldPriceTiyin: 42000000, saleCount: 67, viewCount: 2100,
      photos: ['https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600&q=80'] },
    // Kamola Beauty
    { sellerId: kamolaId, categoryId: catMap['beauty'],
      title: 'Сыворотка с витамином C', isBoosted: true,
      priceTiyin: 18900000, saleCount: 312, viewCount: 12400,
      photos: ['https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=600&q=80',
               'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=600&q=80'] },
    { sellerId: kamolaId, categoryId: catMap['beauty'],
      title: 'Палетка теней 12 оттенков',
      priceTiyin: 24000000, oldPriceTiyin: 35000000, saleCount: 189, viewCount: 7800,
      photos: ['https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&q=80'] },
    { sellerId: kamolaId, categoryId: catMap['beauty'],
      title: 'Парфюм Rose Musk 50ml', isBoosted: true,
      priceTiyin: 45000000, saleCount: 456, viewCount: 28900,
      photos: ['https://images.unsplash.com/photo-1541643600914-78b084683702?w=600&q=80',
               'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=600&q=80'] },
    // TechZone
    { sellerId: techId, categoryId: catMap['tech'],
      title: 'Наушники TWS Pro', isBoosted: true,
      priceTiyin: 38000000, oldPriceTiyin: 52000000, saleCount: 234, viewCount: 15600,
      photos: ['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80',
               'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80'] },
    { sellerId: techId, categoryId: catMap['tech'],
      title: 'Смарт-часы GT4 Pro',
      priceTiyin: 52000000, oldPriceTiyin: 70000000, saleCount: 178, viewCount: 9800,
      photos: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80'] },
    { sellerId: techId, categoryId: catMap['tech'],
      title: 'Чехол iPhone 15 Pro',
      priceTiyin: 8900000, saleCount: 567, viewCount: 4500,
      photos: ['https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=600&q=80'] },
    // Home
    { sellerId: homeId, categoryId: catMap['home'],
      title: 'Диван угловой серый',
      priceTiyin: 450000000, oldPriceTiyin: 580000000, saleCount: 23, viewCount: 1200,
      photos: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
               'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80'] },
    { sellerId: homeId, categoryId: catMap['home'],
      title: 'Набор ароматических свечей',
      priceTiyin: 8500000, saleCount: 345, viewCount: 6700,
      photos: ['https://images.unsplash.com/photo-1572726729207-a78d6feb18d7?w=600&q=80'] },
    // Sport
    { sellerId: sportId, categoryId: catMap['shoes'],
      title: 'Кроссовки для бега', isBoosted: true,
      priceTiyin: 38000000, oldPriceTiyin: 52000000, saleCount: 456, viewCount: 23400,
      photos: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
               'https://images.unsplash.com/photo-1539185441755-769473a23570?w=600&q=80'] },
    { sellerId: sportId, categoryId: catMap['sport'],
      title: 'Коврик для йоги NBR',
      priceTiyin: 12000000, saleCount: 234, viewCount: 5600,
      photos: ['https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&q=80'] },
  ];

  const prodIds: string[] = [];
  for (const p of productInputs) {
    const { photos, isBoosted, ...fields } = p;
    const [prod] = await db.insert(products).values({
      ...fields,
      description: 'Качественный товар от проверенного продавца. Быстрая доставка по всему Узбекистану.',
      status: 'active',
      avgRating: parseFloat((4.5 + Math.random() * 0.4).toFixed(1)),
      reviewCount: Math.floor(Math.random() * 200) + 10,
      isBoosted: isBoosted ?? false,
    }).returning();
    for (let i = 0; i < photos.length; i++) {
      await db.insert(productPhotos).values({ productId: prod.id, url: photos[i], order: i, isMain: i === 0 });
    }
    prodIds.push(prod.id);
  }
  console.log('✓ Products:', prodIds.length);

  // ── Reels ─────────────────────────────────────────────────────────────────
  const reelInputs = [
    { sellerId: aishaId,  productId: prodIds[0],
      title: 'Платье которое носят все этим летом 🌸',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&q=80',
      likeCount: 12400, viewCount: 89000 },
    { sellerId: kamolaId, productId: prodIds[4],
      title: 'Кожа как шёлк за 7 дней — мой уход ✨',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&q=80',
      likeCount: 28900, viewCount: 156000 },
    { sellerId: techId,   productId: prodIds[7],
      title: 'Честный обзор TWS за 380К 🎧',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&q=80',
      likeCount: 8900, viewCount: 45000 },
    { sellerId: sportId,  productId: prodIds[12],
      title: 'Утренняя пробежка 5км в новых кроссах 💪',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
      likeCount: 15600, viewCount: 78000 },
    { sellerId: kamolaId, productId: prodIds[5],
      title: 'Макияж за 5 минут с нашей палеткой 💋',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&q=80',
      likeCount: 45000, viewCount: 234000 },
    { sellerId: aishaId,  productId: prodIds[1],
      title: 'Пальто оверсайз — хит осени 🧥',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&q=80',
      likeCount: 32000, viewCount: 189000 },
    { sellerId: homeId,   productId: prodIds[11],
      title: 'Уютный вечер дома 🕯️',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1572726729207-a78d6feb18d7?w=400&q=80',
      likeCount: 7800, viewCount: 34000 },
    { sellerId: kamolaId, productId: prodIds[6],
      title: 'Rose Musk — аромат для неё 🌹',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      thumbUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683702?w=400&q=80',
      likeCount: 52000, viewCount: 298000 },
  ];

  for (const r of reelInputs) {
    await db.insert(reels).values({ ...r, status: 'active' }).onConflictDoNothing();
  }
  console.log('✓ Reels:', reelInputs.length);

  console.log('\n✅ Done! Данные загружены в базу.');
  process.exit(0);
}

seed().catch(e => { console.error('❌', e.message); process.exit(1); });
