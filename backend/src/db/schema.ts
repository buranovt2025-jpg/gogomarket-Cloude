import {
  pgTable, uuid, varchar, text, integer, bigint, boolean,
  timestamp, pgEnum, jsonb, index, uniqueIndex, real
} from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// ── Enums ────────────────────────────────────────────────────────
export const userRoleEnum    = pgEnum('user_role',    ['buyer', 'seller', 'courier', 'admin', 'superadmin']);
export const sellerPlanEnum  = pgEnum('seller_plan',  ['private', 'basic', 'start', 'business', 'shop']);
export const listingTypeEnum = pgEnum('listing_type', ['product', 'reel', 'story']);
export const productStatusEnum = pgEnum('product_status', ['draft', 'pending', 'active', 'out_of_stock', 'rejected', 'deleted']);
export const orderStatusEnum = pgEnum('order_status', ['new', 'confirmed', 'packed', 'delivery', 'delivered', 'done', 'cancelled', 'dispute']);
export const messageTypeEnum = pgEnum('message_type', ['text', 'image', 'audio', 'offer', 'system']);
export const disputeStatusEnum = pgEnum('dispute_status', ['open', 'under_review', 'resolved_buyer', 'resolved_seller', 'closed']);
export const deliveryServiceEnum = pgEnum('delivery_service', ['self', 'express24', 'yandex', 'gogoexpress']);
export const paymentProviderEnum = pgEnum('payment_provider', ['click', 'payme', 'cash', 'gogocoins']);
export const paymentStatusEnum   = pgEnum('payment_status', ['pending', 'paid', 'failed', 'refunded']);
export const notifTypeEnum = pgEnum('notif_type', ['order', 'delivery', 'chat', 'promo', 'review', 'follow', 'system', 'dispute']);

// ── Tables ───────────────────────────────────────────────────────

export const users = pgTable('users', {
  id:          uuid('id').defaultRandom().primaryKey(),
  phone:       varchar('phone', { length: 20 }).notNull().unique(),
  name:        varchar('name', { length: 120 }),
  avatarUrl:   text('avatar_url'),
  role:        userRoleEnum('role').notNull().default('buyer'),
  tier:        integer('tier').notNull().default(1), // 1=buyer 2=private_seller 3=business
  isVerified:  boolean('is_verified').notNull().default(false),
  fcmToken:    text('fcm_token'),
  createdAt:   timestamp('created_at').defaultNow().notNull(),
  updatedAt:   timestamp('updated_at').defaultNow().notNull(),
  deletedAt:   timestamp('deleted_at'),
}, (t) => ({
  phoneIdx: index('users_phone_idx').on(t.phone),
}));

export const sellers = pgTable('sellers', {
  id:          uuid('id').defaultRandom().primaryKey(),
  userId:      uuid('user_id').notNull().references(() => users.id),
  shopName:    varchar('shop_name', { length: 120 }).notNull(),
  description: text('description'),
  logoUrl:     text('logo_url'),
  inn:         varchar('inn', { length: 9 }),
  passportUrl: text('passport_url'),
  plan:        sellerPlanEnum('plan').notNull().default('basic'),
  isVerified:  boolean('is_verified').notNull().default(false),
  isRejected:  boolean('is_rejected').notNull().default(false),
  avgRating:   real('avg_rating').default(0),
  reviewCount: integer('review_count').default(0),
  followerCount: integer('follower_count').default(0),
  createdAt:   timestamp('created_at').defaultNow().notNull(),
  updatedAt:   timestamp('updated_at').defaultNow().notNull(),
}, (t) => ({
  userIdx: uniqueIndex('sellers_user_id_idx').on(t.userId),
}));

export const subscriptions = pgTable('subscriptions', {
  id:        uuid('id').defaultRandom().primaryKey(),
  sellerId:  uuid('seller_id').notNull().references(() => sellers.id),
  plan:      sellerPlanEnum('plan').notNull(),
  startedAt: timestamp('started_at').defaultNow().notNull(),
  expiresAt: timestamp('expires_at').notNull(),
  isActive:  boolean('is_active').notNull().default(true),
  externalPaymentId: text('external_payment_id'),
});

export const categories = pgTable('categories', {
  id:       uuid('id').defaultRandom().primaryKey(),
  name:     varchar('name', { length: 80 }).notNull(),
  nameUz:   varchar('name_uz', { length: 80 }),
  slug:     varchar('slug', { length: 80 }).notNull().unique(),
  icon:     varchar('icon', { length: 10 }),
  parentId: uuid('parent_id'),
  sortOrder: integer('sort_order').default(0),
});

export const products = pgTable('products', {
  id:          uuid('id').defaultRandom().primaryKey(),
  sellerId:    uuid('seller_id').notNull().references(() => sellers.id),
  categoryId:  uuid('category_id').references(() => categories.id),
  title:       varchar('title', { length: 200 }).notNull(),
  expiresAt:   timestamp('expires_at'), // null = no expiry (tier 3); set = tier 2 (7 days)
  description: text('description'),
  priceTiyin:  bigint('price_tiyin', { mode: 'number' }).notNull(),
  oldPriceTiyin: bigint('old_price_tiyin', { mode: 'number' }),
  stock:       integer('stock').notNull().default(0),
  status:      productStatusEnum('status').notNull().default('draft'),
  condition:   varchar('condition', { length: 20 }).default('new'), // new | used
  deliveryType: varchar('delivery_type', { length: 20 }).default('self'), // self | courier | both
  tags:        text('tags').array(),
  viewCount:   integer('view_count').default(0),
  saleCount:   integer('sale_count').default(0),
  avgRating:   real('avg_rating').default(0),
  reviewCount: integer('review_count').default(0),
  isBoosted:   boolean('is_boosted').default(false),
  boostEndsAt: timestamp('boost_ends_at'),
  createdAt:   timestamp('created_at').defaultNow().notNull(),
  updatedAt:   timestamp('updated_at').defaultNow().notNull(),
  deletedAt:   timestamp('deleted_at'),
}, (t) => ({
  sellerIdx:   index('products_seller_idx').on(t.sellerId),
  statusIdx:   index('products_status_idx').on(t.status),
  categoryIdx: index('products_category_idx').on(t.categoryId),
}));

export const productPhotos = pgTable('product_photos', {
  id:        uuid('id').defaultRandom().primaryKey(),
  productId: uuid('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  url:       text('url').notNull(),
  order:     integer('order').notNull().default(0),
  isMain:    boolean('is_main').default(false),
});

export const productVariants = pgTable('product_variants', {
  id:            uuid('id').defaultRandom().primaryKey(),
  productId:     uuid('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  size:          varchar('size', { length: 20 }),
  color:         varchar('color', { length: 40 }),
  material:      varchar('material', { length: 60 }),
  stock:         integer('stock').notNull().default(0),
  priceDiffTiyin: bigint('price_diff_tiyin', { mode: 'number' }).default(0),
});

export const reels = pgTable('reels', {
  id:         uuid('id').defaultRandom().primaryKey(),
  sellerId:   uuid('seller_id').notNull().references(() => sellers.id),
  productId:  uuid('product_id').references(() => products.id),
  videoUrl:   text('video_url').notNull(),
  thumbUrl:   text('thumb_url'),
  hlsUrl:     text('hls_url'),
  title:      varchar('title', { length: 200 }),
  description: text('description'),
  duration:   integer('duration'), // seconds
  viewCount:  integer('view_count').default(0),
  likeCount:  integer('like_count').default(0),
  shareCount: integer('share_count').default(0),
  status:     varchar('status', { length: 20 }).default('processing'), // processing|active|rejected
  audience:   varchar('audience', { length: 20 }).default('all'), // all|followers|boosted
  createdAt:  timestamp('created_at').defaultNow().notNull(),
  deletedAt:  timestamp('deleted_at'),
}, (t) => ({
  sellerIdx: index('reels_seller_idx').on(t.sellerId),
}));

export const orders = pgTable('orders', {
  id:              uuid('id').defaultRandom().primaryKey(),
  buyerId:         uuid('buyer_id').notNull().references(() => users.id),
  sellerId:        uuid('seller_id').notNull().references(() => sellers.id),
  courierId:       uuid('courier_id').references(() => couriers.id),
  status:          orderStatusEnum('status').notNull().default('new'),
  totalTiyin:      bigint('total_tiyin', { mode: 'number' }).notNull(),
  deliveryService: deliveryServiceEnum('delivery_service').notNull().default('self'),
  deliveryAddress: text('delivery_address'),
  deliveryLat:     real('delivery_lat'),
  deliveryLng:     real('delivery_lng'),
  trackingId:      varchar('tracking_id', { length: 60 }),
  buyerNote:       text('buyer_note'),
  sellerNote:      text('seller_note'),
  createdAt:       timestamp('created_at').defaultNow().notNull(),
  updatedAt:       timestamp('updated_at').defaultNow().notNull(),
  completedAt:     timestamp('completed_at'),
}, (t) => ({
  buyerIdx:  index('orders_buyer_idx').on(t.buyerId),
  sellerIdx: index('orders_seller_idx').on(t.sellerId),
  statusIdx: index('orders_status_idx').on(t.status),
}));

export const orderItems = pgTable('order_items', {
  id:        uuid('id').defaultRandom().primaryKey(),
  orderId:   uuid('order_id').notNull().references(() => orders.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  variantId: uuid('variant_id').references(() => productVariants.id),
  title:     varchar('title', { length: 200 }).notNull(), // snapshot
  photoUrl:  text('photo_url'),
  quantity:  integer('quantity').notNull().default(1),
  priceTiyin: bigint('price_tiyin', { mode: 'number' }).notNull(),
});

export const couriers = pgTable('couriers', {
  id:           uuid('id').defaultRandom().primaryKey(),
  userId:       uuid('user_id').notNull().references(() => users.id),
  vehicleType:  varchar('vehicle_type', { length: 30 }).notNull(),
  plate:        varchar('plate', { length: 20 }),
  zone:         text('zone').array(),
  isOnline:     boolean('is_online').default(false),
  currentLat:   real('current_lat'),
  currentLng:   real('current_lng'),
  lastSeenAt:   timestamp('last_seen_at'),
  isVerified:   boolean('is_verified').default(false),
  avgRating:    real('avg_rating').default(5.0),
  tripCount:    integer('trip_count').default(0),
  createdAt:    timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  userIdx: uniqueIndex('couriers_user_idx').on(t.userId),
}));

export const chats = pgTable('chats', {
  id:            uuid('id').defaultRandom().primaryKey(),
  buyerId:       uuid('buyer_id').notNull().references(() => users.id),
  sellerId:      uuid('seller_id').notNull().references(() => sellers.id),
  lastMessageAt: timestamp('last_message_at').defaultNow(),
  buyerUnread:   integer('buyer_unread').default(0),
  sellerUnread:  integer('seller_unread').default(0),
  createdAt:     timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  uniqueChat: uniqueIndex('chats_buyer_seller_idx').on(t.buyerId, t.sellerId),
}));

export const messages = pgTable('messages', {
  id:         uuid('id').defaultRandom().primaryKey(),
  chatId:     uuid('chat_id').notNull().references(() => chats.id),
  senderId:   uuid('sender_id').notNull().references(() => users.id),
  type:       messageTypeEnum('type').notNull().default('text'),
  content:    text('content'),
  mediaUrl:   text('media_url'),
  offerProductId: uuid('offer_product_id').references(() => products.id),
  isRead:     boolean('is_read').default(false),
  readAt:     timestamp('read_at'),
  createdAt:  timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  chatIdx: index('messages_chat_idx').on(t.chatId, t.createdAt),
}));

export const reviews = pgTable('reviews', {
  id:        uuid('id').defaultRandom().primaryKey(),
  orderId:   uuid('order_id').notNull().references(() => orders.id),
  buyerId:   uuid('buyer_id').notNull().references(() => users.id),
  sellerId:  uuid('seller_id').notNull().references(() => sellers.id),
  productId: uuid('product_id').references(() => products.id),
  rating:    integer('rating').notNull(), // 1-5
  text:      text('text'),
  photoUrls: text('photo_urls').array(),
  isVisible: boolean('is_visible').default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  orderIdx: uniqueIndex('reviews_order_idx').on(t.orderId),
}));

export const disputes = pgTable('disputes', {
  id:         uuid('id').defaultRandom().primaryKey(),
  orderId:    uuid('order_id').notNull().references(() => orders.id),
  openerId:   uuid('opener_id').notNull().references(() => users.id),
  reason:     text('reason').notNull(),
  status:     disputeStatusEnum('status').notNull().default('open'),
  adminNote:  text('admin_note'),
  resolvedAt: timestamp('resolved_at'),
  createdAt:  timestamp('created_at').defaultNow().notNull(),
});

export const notifications = pgTable('notifications', {
  id:        uuid('id').defaultRandom().primaryKey(),
  userId:    uuid('user_id').notNull().references(() => users.id),
  type:      notifTypeEnum('type').notNull(),
  title:     varchar('title', { length: 200 }).notNull(),
  body:      text('body'),
  meta:      jsonb('meta'),
  isRead:    boolean('is_read').default(false),
  readAt:    timestamp('read_at'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  userIdx: index('notifications_user_idx').on(t.userId, t.isRead),
}));

export const payments = pgTable('payments', {
  id:             uuid('id').defaultRandom().primaryKey(),
  orderId:        uuid('order_id').notNull().references(() => orders.id),
  provider:       paymentProviderEnum('provider').notNull(),
  amountTiyin:    bigint('amount_tiyin', { mode: 'number' }).notNull(),
  status:         paymentStatusEnum('status').notNull().default('pending'),
  externalId:     text('external_id'),
  externalMeta:   jsonb('external_meta'),
  paidAt:         timestamp('paid_at'),
  createdAt:      timestamp('created_at').defaultNow().notNull(),
});

export const auditLogs = pgTable('audit_logs', {
  id:         uuid('id').defaultRandom().primaryKey(),
  adminId:    uuid('admin_id').notNull().references(() => users.id),
  action:     varchar('action', { length: 100 }).notNull(),
  targetType: varchar('target_type', { length: 50 }),
  targetId:   uuid('target_id'),
  before:     jsonb('before'),
  after:      jsonb('after'),
  ip:         varchar('ip', { length: 45 }),
  createdAt:  timestamp('created_at').defaultNow().notNull(),
});

// Tracks tier-2 expiry + renewal (products and reels auto-delete after 7d)
export const listingExpirations = pgTable('listing_expirations', {
  id:          uuid('id').defaultRandom().primaryKey(),
  listingType: listingTypeEnum('listing_type').notNull(),
  listingId:   uuid('listing_id').notNull(),
  userId:      uuid('user_id').notNull().references(() => users.id),
  expiresAt:   timestamp('expires_at').notNull(),
  notifiedAt:  timestamp('notified_at'),  // when "3 days left" push was sent
  renewedAt:   timestamp('renewed_at'),   // if user paid to renew
  deletedAt:   timestamp('deleted_at'),   // when auto-deleted by cron
  createdAt:   timestamp('created_at').defaultNow().notNull(),
}, (t) => ({
  listingIdx: index('listing_exp_listing_idx').on(t.listingType, t.listingId),
  expiryIdx:  index('listing_exp_expires_idx').on(t.expiresAt),
}));

// ── Relations ────────────────────────────────────────────────────
export const usersRelations = relations(users, ({ one, many }) => ({
  seller:        one(sellers, { fields: [users.id], references: [sellers.userId] }),
  courier:       one(couriers, { fields: [users.id], references: [couriers.userId] }),
  buyerOrders:   many(orders),
  notifications: many(notifications),
}));

export const sellersRelations = relations(sellers, ({ one, many }) => ({
  user:          one(users, { fields: [sellers.userId], references: [users.id] }),
  products:      many(products),
  reels:         many(reels),
  subscriptions: many(subscriptions),
}));

export const productsRelations = relations(products, ({ one, many }) => ({
  seller:   one(sellers, { fields: [products.sellerId], references: [sellers.id] }),
  category: one(categories, { fields: [products.categoryId], references: [categories.id] }),
  photos:   many(productPhotos),
  variants: many(productVariants),
  reviews:  many(reviews),
}));

export const ordersRelations = relations(orders, ({ one, many }) => ({
  buyer:   one(users, { fields: [orders.buyerId], references: [users.id] }),
  seller:  one(sellers, { fields: [orders.sellerId], references: [sellers.id] }),
  courier: one(couriers, { fields: [orders.courierId], references: [couriers.id] }),
  items:   many(orderItems),
  payment: one(payments, { fields: [orders.id], references: [payments.orderId] }),
  review:  one(reviews, { fields: [orders.id], references: [reviews.orderId] }),
  dispute: one(disputes, { fields: [orders.id], references: [disputes.orderId] }),
}));
