import { Request } from 'express';
import { JwtPayload } from '../utils/jwt';

export interface AuthRequest extends Request {
  user: JwtPayload;
}

export type UserRole = 'buyer' | 'seller' | 'courier' | 'admin' | 'superadmin';
export type OrderStatus = 'new' | 'confirmed' | 'packed' | 'delivery' | 'delivered' | 'done' | 'cancelled' | 'dispute';
export type ProductStatus = 'draft' | 'pending' | 'active' | 'out_of_stock' | 'rejected' | 'deleted';
export type SellerPlan = 'basic' | 'start' | 'business' | 'shop';
export type DeliveryService = 'self' | 'express24' | 'yandex' | 'gogoexpress';

export interface PaginatedResponse<T> {
  items: T[];
  page: number;
  limit: number;
  total?: number;
}

export interface ApiError {
  error: string;
  details?: unknown;
  code?: string;
}
