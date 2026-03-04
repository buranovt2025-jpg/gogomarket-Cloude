/**
 * Dev seed — creates sample data for local development.
 * Run: npx tsx scripts/seed.ts
 */
import 'dotenv/config';
import { db } from '../src/db';
import { users, sellers, categories, products, productPhotos } from '../src/db/schema';

async function seed() {
  console.log('🌱 Seeding database...');

  // Categories
  const cats = await db.insert(categories).values([
    { name: 'Мода', nameUz: 'Moda',         slug: 'fashion',     icon: '👗', sortOrder: 1 },
    { name: 'Обувь', nameUz: 'Oyoq kiyim',  slug: 'shoes',       icon: '👟', sortOrder: 2 },
    { name: 'Техника', nameUz: 'Texnika',   slug: 'electronics', icon: '📱', sortOrder: 3 },
    { name: 'Дом', nameUz: 'Uy',            slug: 'home',        icon: '🏡', sortOrder: 4 },
    { name: 'Красота', nameUz: "Go'zallik", slug: 'beauty',      icon: '💄', sortOrder: 5 },
    { name: 'Спорт', nameUz: 'Sport',       slug: 'sport',       icon: '⚽', sortOrder: 6 },
  ]).returning().onConflictDoNothing();

  console.log(`✅ ${cats.length} categories created`);

  // Test buyer
  const [buyer] = await db.insert(users).values({
    phone: '+998901234567',
    name:  'Камола Юсупова',
    role:  'buyer',
    isVerified: true,
  }).returning().onConflictDoNothing();

  // Test seller user
  const [sellerUser] = await db.insert(users).values({
    phone: '+998909876543',
    name:  'Малика Расулова',
    role:  'seller',
    isVerified: true,
  }).returning().onConflictDoNothing();

  if (sellerUser) {
    const [seller] = await db.insert(sellers).values({
      userId:    sellerUser.id,
      shopName:  'Aisha Fashion Store',
      inn:       '123456789',
      isVerified: true,
      plan:      'business',
      avgRating: 4.9,
      reviewCount: 124,
    }).returning().onConflictDoNothing();

    if (seller && cats.length) {
      const fashionCat = cats.find(c => c.slug === 'fashion');
      const [product] = await db.insert(products).values({
        sellerId:    seller.id,
        categoryId:  fashionCat?.id,
        title:       'Шёлковое платье',
        description: 'Изящное шёлковое платье из натуральной ткани.',
        priceTiyin:  8_500_000, // 85,000 сум
        oldPriceTiyin: 10_000_000,
        stock:       15,
        status:      'active',
        condition:   'new',
        tags:        ['платье', 'шёлк', 'мода'],
        avgRating:   4.8,
        reviewCount: 124,
      }).returning().onConflictDoNothing();

      if (product) {
        await db.insert(productPhotos).values({
          productId: product.id,
          url: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=800&q=80',
          order: 0,
          isMain: true,
        }).onConflictDoNothing();
        console.log(`✅ Product "${product.title}" created`);
      }
    }
  }

  console.log('✅ Seed complete');
  process.exit(0);
}

seed().catch(err => {
  console.error('Seed failed:', err);
  process.exit(1);
});
