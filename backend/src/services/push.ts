import { logger } from '../utils/logger';

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

// TODO: integrate Firebase Admin SDK
export const sendPushNotification = async (
  fcmToken: string,
  payload: PushPayload
): Promise<void> => {
  if (process.env.NODE_ENV !== 'production') {
    logger.info({ fcmToken: fcmToken.slice(0, 10) + '...', payload }, '[DEV] Push not sent');
    return;
  }
  // firebase-admin implementation goes here
  logger.info({ payload }, 'Push notification sent');
};
