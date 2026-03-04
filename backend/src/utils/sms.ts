import axios from 'axios';
import { redis } from './redis';
import { logger } from './logger';

const OTP_TTL = 60; // seconds
const OTP_PREFIX = 'otp:';

export const generateOtp = () =>
  Math.floor(1000 + Math.random() * 9000).toString();

export const saveOtp = (phone: string, otp: string) =>
  redis.setEx(`${OTP_PREFIX}${phone}`, OTP_TTL, otp);

export const verifyOtp = async (phone: string, code: string): Promise<boolean> => {
  const stored = await redis.get(`${OTP_PREFIX}${phone}`);
  if (!stored || stored !== code) return false;
  await redis.del(`${OTP_PREFIX}${phone}`);
  return true;
};

let eskizToken: string | null = null;

const getEskizToken = async (): Promise<string> => {
  if (eskizToken) return eskizToken;
  const { data } = await axios.post('https://notify.eskiz.uz/api/auth/login', {
    email: process.env.ESKIZ_EMAIL,
    password: process.env.ESKIZ_PASSWORD,
  });
  eskizToken = data.data.token;
  return eskizToken!;
};

export const sendSms = async (phone: string, text: string): Promise<void> => {
  if (process.env.NODE_ENV !== 'production') {
    logger.info({ phone, text }, '[DEV] SMS not sent');
    return;
  }
  try {
    const token = await getEskizToken();
    await axios.post(
      'https://notify.eskiz.uz/api/message/sms/send',
      { mobile_phone: phone.replace('+', ''), message: text, from: process.env.ESKIZ_FROM },
      { headers: { Authorization: `Bearer ${token}` } }
    );
  } catch (err) {
    logger.error({ err, phone }, 'SMS sending failed');
    throw err;
  }
};

export const sendOtp = async (phone: string): Promise<string> => {
  const otp = generateOtp();
  await saveOtp(phone, otp);
  await sendSms(phone, `GogoMarket: ваш код ${otp}. Никому не сообщайте.`);
  return otp;
};
