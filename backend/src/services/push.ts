import { logger } from '../utils/logger';

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Send FCM push via legacy HTTP API.
 * Requires FIREBASE_SERVER_KEY in .env
 */
export const sendPushNotification = async (
  fcmToken: string,
  payload: PushPayload
): Promise<void> => {
  const serverKey = process.env.FIREBASE_SERVER_KEY;
  if (!serverKey) {
    logger.info({ payload }, '[Push] FIREBASE_SERVER_KEY not set — skipping');
    return;
  }
  if (!fcmToken) return;

  try {
    const res = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${serverKey}`,
      },
      body: JSON.stringify({
        to: fcmToken,
        notification: { title: payload.title, body: payload.body, sound: 'default' },
        data: payload.data ?? {},
        priority: 'high',
      }),
    });

    const json = await res.json() as any;
    if (json.failure > 0) {
      logger.warn({ fcmToken: fcmToken.slice(0, 12), error: json.results?.[0] }, 'FCM delivery failed');
    } else {
      logger.info({ title: payload.title }, 'Push sent');
    }
  } catch (err) {
    logger.error({ err }, 'Push send error');
  }
};

/**
 * Send push to a user by userId — fetches their fcmToken from DB
 */
export const sendPushToUser = async (
  userId: string,
  payload: PushPayload
): Promise<void> => {
  const { db } = await import('../db');
  const { users } = await import('../db/schema');
  const { eq } = await import('drizzle-orm');

  const [user] = await db.select({ fcmToken: users.fcmToken })
    .from(users).where(eq(users.id, userId)).limit(1);

  if (!user?.fcmToken) return;
  await sendPushNotification(user.fcmToken, payload);
};
