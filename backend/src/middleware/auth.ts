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

/** Check user has at least the given tier (1=buyer, 2=private_seller, 3=business) */
export const requireTier = (minTier: number) =>
  (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) throw new AppError(401, 'Unauthorized');
    if ((req.user.tier ?? 1) < minTier) {
      throw new AppError(403, `Requires tier ${minTier}. Upgrade in your profile.`);
    }
    next();
  };

/** Check user has one of the given system roles */
export const requireRole = (...roles: string[]) =>
  (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      throw new AppError(403, 'Forbidden: insufficient permissions');
    }
    next();
  };

// Convenience helpers
export const requireSeller  = requireTier(2);          // tier 2+ can sell
export const requireBusiness = requireTier(3);          // tier 3 only
export const requireCourier = requireRole('courier', 'admin', 'superadmin');
export const requireAdmin   = requireRole('admin', 'superadmin');
