import jwt, { SignOptions } from 'jsonwebtoken';

export interface JwtPayload {
  userId: string;
  role: string;
  sellerId?: string;
  courierId?: string;
}

export const signAccessToken = (payload: JwtPayload) =>
  jwt.sign(payload, process.env.JWT_ACCESS_SECRET!, {
    expiresIn: (process.env.JWT_ACCESS_EXPIRES_IN || '15m') as SignOptions['expiresIn'],
  });

export const signRefreshToken = (payload: JwtPayload) =>
  jwt.sign(payload, process.env.JWT_REFRESH_SECRET!, {
    expiresIn: (process.env.JWT_REFRESH_EXPIRES_IN || '30d') as SignOptions['expiresIn'],
  });

export const verifyAccessToken = (token: string) =>
  jwt.verify(token, process.env.JWT_ACCESS_SECRET!) as JwtPayload;

export const verifyRefreshToken = (token: string) =>
  jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as JwtPayload;
