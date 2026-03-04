import { createClient } from 'redis';
import { logger } from './logger';

export const redis = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379',
});

redis.on('error', (err) => logger.error({ err }, 'Redis error'));
redis.on('connect', () => logger.info('Redis connected'));

redis.connect().catch((err) => {
  logger.error({ err }, 'Failed to connect to Redis');
  process.exit(1);
});

export const setex = (key: string, ttlSeconds: number, value: string) =>
  redis.setEx(key, ttlSeconds, value);

export const getdel = (key: string) => redis.getDel(key);
