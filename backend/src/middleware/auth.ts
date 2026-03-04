import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, JwtPayload } from '../utils/jwt';
import { AppError } from './errorHandler';

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}

export const authenticate = (req: Request, _res: Response, next: NextFunction) => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) throw new AppError(401, 'Unauthorized');
  try {
    req.user = verifyAccessToken(header.slice(7));
    next();
  } catch {
    throw new AppError(401, 'Token expired or invalid');
  }
};

export const requireRole = (...roles: string[]) =>
  (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      throw new AppError(403, 'Forbidden: insufficient permissions');
    }
    next();
  };

export const requireSeller = requireRole('seller', 'admin', 'superadmin');
export const requireCourier = requireRole('courier', 'admin', 'superadmin');
export const requireAdmin   = requireRole('admin', 'superadmin');
