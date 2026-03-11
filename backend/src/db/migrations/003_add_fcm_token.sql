-- Migration 003: Add fcm_token to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
