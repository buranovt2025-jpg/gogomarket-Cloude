import axios from 'axios';
import { redis } from './redis';
import { logger } from './logger';

const OTP_TTL    = 120; // 2 minutes
const OTP_PREFIX = 'otp:';
const TOKEN_KEY  = 'eskiz:token';

// Test numbers always get code 1234
const TEST_PHONES = ['+998907654321', '+998901234567', '+998900000000'];

export const generateOtp = (): string =>
  Math.floor(1000 + Math.random() * 9000).toString();

export const saveOtp = (phone: string, otp: string): Promise<any> =>
  redis.setEx(`${OTP_PREFIX}${phone}`, OTP_TTL, otp);

export const verifyOtp = async (phone: string, code: string): Promise<boolean> => {
  // Test phones
  if (TEST_PHONES.includes(phone) && code === '1234') return true;
  const stored = await redis.get(`${OTP_PREFIX}${phone}`);
  if (!stored || stored !== code) return false;
  await redis.del(`${OTP_PREFIX}${phone}`);
  return true;
};

// ── Eskiz token management ────────────────────────────────────────────────────
const getEskizToken = async (): Promise<string> => {
  // Try Redis cache first (token valid 29 days)
  const cached = await redis.get(TOKEN_KEY);
  if (cached) return cached;

  if (!process.env.ESKIZ_EMAIL || !process.env.ESKIZ_PASSWORD) {
    throw new Error('ESKIZ_EMAIL and ESKIZ_PASSWORD env vars not set');
  }

  const { data } = await axios.post('https://notify.eskiz.uz/api/auth/login', {
    email:    process.env.ESKIZ_EMAIL,
    password: process.env.ESKIZ_PASSWORD,
  });

  const token: string = data.data.token;
  // Cache for 29 days (token expires in 30)
  await redis.setEx(TOKEN_KEY, 29 * 24 * 3600, token);
  logger.info('Eskiz token refreshed and cached');
  return token;
};

// Force token refresh (call if you get 401 from Eskiz)
export const refreshEskizToken = async (): Promise<void> => {
  await redis.del(TOKEN_KEY);
  await getEskizToken();
};

// ── Send SMS ──────────────────────────────────────────────────────────────────
export const sendSms = async (phone: string, text: string): Promise<void> => {
  if (process.env.NODE_ENV !== 'production' && !process.env.ESKIZ_EMAIL) {
    logger.info({ phone, text }, '[DEV] SMS skipped (no ESKIZ_EMAIL)');
    return;
  }

  let token: string;
  try {
    token = await getEskizToken();
  } catch (err) {
    logger.error({ err }, 'Failed to get Eskiz token');
    throw err;
  }

  try {
    await axios.post(
      'https://notify.eskiz.uz/api/message/sms/send',
      {
        mobile_phone: phone.replace('+', ''),
        message:      text,
        from:         process.env.ESKIZ_FROM || '4546',
        callback_url: '',
      },
      { headers: { Authorization: `Bearer ${token}` } },
    );
    logger.info({ phone }, 'SMS sent via Eskiz');
  } catch (err: any) {
    // Token expired → refresh and retry once
    if (err?.response?.status === 401) {
      logger.warn('Eskiz token expired, refreshing...');
      await redis.del(TOKEN_KEY);
      const newToken = await getEskizToken();
      await axios.post(
        'https://notify.eskiz.uz/api/message/sms/send',
        {
          mobile_phone: phone.replace('+', ''),
          message:      text,
          from:         process.env.ESKIZ_FROM || '4546',
        },
        { headers: { Authorization: `Bearer ${newToken}` } },
      );
    } else {
      logger.error({ err, phone }, 'SMS sending failed');
      throw err;
    }
  }
};

// ── Send OTP ──────────────────────────────────────────────────────────────────
export const sendOtp = async (phone: string): Promise<void> => {
  if (TEST_PHONES.includes(phone)) {
    await saveOtp(phone, '1234');
    logger.info({ phone }, '[TEST] OTP=1234 for test number');
    return;
  }

  const otp = generateOtp();
  await saveOtp(phone, otp);

  const text = `GogoMarket: ваш код подтверждения ${otp}. Действителен 2 минуты. Никому не сообщайте.`;
  await sendSms(phone, text);
};
