import { rateLimit } from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS) || 60_000,
  max: Number(process.env.RATE_LIMIT_MAX) || 100,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.path === '/health',
  message: { error: 'Too many requests, please try again later' },
});

export const otpRateLimiter = rateLimit({
  windowMs: 60_000,
  max: Number(process.env.OTP_RATE_LIMIT_MAX) || 5,
  message: { error: 'Too many OTP requests' },
});
