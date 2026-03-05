import { Router } from 'express';
import { AppError } from '../middleware/errorHandler';
import { authenticate } from '../middleware/auth';

const router = Router();

// GET /v1/delivery/services
router.get('/services', (_req, res) => {
  res.json([
    { id: 'self', name: 'Самодоговорённость', eta: 'По договорённости', price: 0, available: true },
    { id: 'express24', name: 'Express24', eta: '1–3 часа', priceFrom: 15_000, available: true },
    { id: 'yandex', name: 'Yandex Delivery', eta: '2–5 часов', priceFrom: 12_000, available: true },
    { id: 'gogoexpress', name: 'GogoMarket Express', eta: '30–90 мин', priceFrom: 20_000, available: false, comingSoon: true },
  ]);
});

// GET /v1/delivery/track/:trackingId
router.get('/track/:trackingId', authenticate, async (req, res) => {
  // TODO: integrate Express24/Yandex tracking API
  res.json({
    trackingId: String(req.params.trackingId),
    status: 'in_transit',
    eta: '15:30–17:00',
    courier: { name: 'Курьер', lat: 41.3111, lng: 69.2797 },
  });
});

export default router;
