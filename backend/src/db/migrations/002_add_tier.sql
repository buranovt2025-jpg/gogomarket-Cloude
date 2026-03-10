-- Migration: Add tier system
-- Run on production: psql $DATABASE_URL -f 002_add_tier.sql

BEGIN;

-- 1. Add tier column to users (default 1 = buyer)
ALTER TABLE users ADD COLUMN IF NOT EXISTS tier INTEGER NOT NULL DEFAULT 1;

-- 2. Backfill tier from existing role:
--    - sellers with basic plan → tier 2 (private seller)
--    - sellers with start/business/shop plan → tier 3 (business)
--    - couriers/admins stay tier 1 (system roles)
UPDATE users u
SET tier = 2
WHERE u.role = 'seller'
  AND EXISTS (
    SELECT 1 FROM sellers s
    WHERE s.user_id = u.id AND s.plan = 'basic'
  );

UPDATE users u
SET tier = 3
WHERE u.role = 'seller'
  AND EXISTS (
    SELECT 1 FROM sellers s
    WHERE s.user_id = u.id AND s.plan IN ('start', 'business', 'shop')
  );

-- 3. Update seller_plan enum to include 'private'
ALTER TYPE seller_plan ADD VALUE IF NOT EXISTS 'private';

-- 4. Add listing_type enum
DO $$ BEGIN
  CREATE TYPE listing_type AS ENUM ('product', 'reel', 'story');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 5. Add expires_at to products (null = no expiry for tier 3)
ALTER TABLE products ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

-- 6. Create listing_expirations table
CREATE TABLE IF NOT EXISTS listing_expirations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_type  listing_type NOT NULL,
  listing_id    UUID NOT NULL,
  user_id       UUID NOT NULL REFERENCES users(id),
  expires_at    TIMESTAMPTZ NOT NULL,
  notified_at   TIMESTAMPTZ,
  renewed_at    TIMESTAMPTZ,
  deleted_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS listing_exp_listing_idx ON listing_expirations(listing_type, listing_id);
CREATE INDEX IF NOT EXISTS listing_exp_expires_idx ON listing_expirations(expires_at);

-- 7. Update sellers with no plan to 'private' (tier 2 private sellers)
UPDATE sellers SET plan = 'private' WHERE plan = 'basic' AND NOT is_verified;

COMMIT;
