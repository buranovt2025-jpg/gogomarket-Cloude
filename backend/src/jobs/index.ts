import { Queue, Worker, QueueEvents } from 'bullmq';
import { redis } from '../utils/redis';
import { logger } from '../utils/logger';
import { sendPushNotification } from '../services/push';
import { sendSms } from '../utils/sms';

const connection = { url: process.env.REDIS_URL || 'redis://localhost:6379' };

// ── Queue definitions ─────────────────────────────────────────
export const pushQueue = new Queue('push-notifications', { connection });
export const smsQueue  = new Queue('sms',               { connection });
export const videoQueue = new Queue('video-processing', { connection });

// ── Workers ───────────────────────────────────────────────────
new Worker('push-notifications', async (job) => {
  const { fcmToken, title, body, data } = job.data;
  await sendPushNotification(fcmToken, { title, body, data });
}, {
  connection,
  concurrency: 20,
  limiter: { max: 100, duration: 1000 }, // 100 push/sec
});

new Worker('sms', async (job) => {
  const { phone, text } = job.data;
  await sendSms(phone, text);
}, {
  connection,
  concurrency: 5,
  limiter: { max: 10, duration: 1000 },
});

new Worker('video-processing', async (job) => {
  const { videoPath, reelId } = job.data;
  logger.info({ reelId }, 'Processing reel video...');
  // TODO: ffmpeg HLS transcoding
  // ffmpeg -i input.mp4 -codec: copy -start_number 0 -hls_time 2 -hls_list_size 0 -f hls output.m3u8
  logger.info({ reelId }, 'Video processing complete');
}, {
  connection,
  concurrency: 2,
});

// ── Helpers ───────────────────────────────────────────────────
export const enqueuePush = (fcmToken: string, title: string, body: string, data?: object) =>
  pushQueue.add('send', { fcmToken, title, body, data }, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 2000 },
  });

export const enqueueSms = (phone: string, text: string) =>
  smsQueue.add('send', { phone, text }, { attempts: 3, backoff: { type: 'fixed', delay: 5000 } });

logger.info('BullMQ workers started');
