require('dotenv').config();
const { db } = require('../dist/db');
const { eq } = require('drizzle-orm');
const { users, sellers } = require('../dist/db/schema');

async function createTestAccounts() {
  console.log('👤 Создаём тестовые аккаунты...\n');

  const accounts = [
    { phone: '+998900000001', name: 'Тимур (Покупатель)',  role: 'buyer'   },
    { phone: '+998900000002', name: 'Aisha (Продавец)',    role: 'seller'  },
    { phone: '+998900000003', name: 'Bobur (Курьер)',      role: 'courier' },
    { phone: '+998900000004', name: 'Admin GogoMarket',    role: 'admin'   },
  ];

  for (const acc of accounts) {
    let [row] = await db.select().from(users).where(eq(users.phone, acc.phone));
    if (!row) {
      [row] = await db.insert(users).values({ ...acc, isVerified: true }).returning();
      console.log(`✅ Создан: ${acc.name} (${acc.phone})`);
    } else {
      await db.update(users).set({ role: acc.role, isVerified: true }).where(eq(users.id, row.id));
      console.log(`✓  Обновлён: ${acc.name} (${acc.phone})`);
    }

    // Создаём профиль продавца для seller аккаунта
    if (acc.role === 'seller') {
      const [existing] = await db.select().from(sellers).where(eq(sellers.userId, row.id));
      if (!existing) {
        await db.insert(sellers).values({
          userId:       row.id,
          shopName:     'Aisha Fashion',
          description:  'Тестовый магазин для демо',
          logoUrl:      'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=200&q=80',
          plan:         'business',
          isVerified:   true,
          avgRating:    4.8,
          reviewCount:  234,
          followerCount: 12400,
        });
        console.log('   → Профиль продавца создан');
      }
    }
  }

  console.log('\n📋 ТЕСТОВЫЕ АККАУНТЫ:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🛍️  Покупатель: +998900000001  код: 1234');
  console.log('🏪  Продавец:   +998900000002  код: 1234');
  console.log('🚚  Курьер:     +998900000003  код: 1234');
  console.log('⚙️   Админ:      +998900000004  код: 1234');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  process.exit(0);
}

createTestAccounts().catch(e => { console.error('❌', e.message); process.exit(1); });
