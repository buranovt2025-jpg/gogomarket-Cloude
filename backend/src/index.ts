import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';
import path from 'path';

import { logger, httpLogger } from './utils/logger';
import { errorHandler }       from './middleware/errorHandler';
import { rateLimiter }        from './middleware/rateLimiter';
import { initSocket }         from './socket';

import authRouter         from './routes/auth';
import feedRouter         from './routes/feed';
import productsRouter     from './routes/products';
import ordersRouter       from './routes/orders';
import pushRouter        from './routes/push';
import paymentsRouter     from './routes/payments';
import chatsRouter        from './routes/chats';
import sellersRouter      from './routes/sellers';
import deliveryRouter     from './routes/delivery';
import notificationsRouter from './routes/notifications';
import adminRouter        from './routes/admin';
import uploadRouter       from './routes/upload';
import reelsRouter        from './routes/reels';

const app    = express();
const server = createServer(app);

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({ origin: process.env.CORS_ORIGINS?.split(',') ?? '*', credentials: true }));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(httpLogger);
app.use(rateLimiter);

// ── Static uploads ────────────────────────────────────────────────────────────
const uploadDir = process.env.UPLOAD_DIR || '/opt/gogomarket-Cloude/uploads';
app.use('/uploads', express.static(uploadDir));

// ── Health ────────────────────────────────────────────────────────────────────
app.get('/health', (_, res) => res.json({
  status:    'ok',
  timestamp: new Date().toISOString(),
  version:   '1.0.0',
}));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',          authRouter);
app.use('/api/feed',          feedRouter);
app.use('/api/products',      productsRouter);
app.use('/api/orders',        ordersRouter);
app.use('/api/chats',         chatsRouter);
app.use('/api/sellers',       sellersRouter);
app.use('/api/delivery',      deliveryRouter);
app.use('/api/notifications', notificationsRouter);
app.use('/api/admin',         adminRouter);
app.use('/api/upload',        uploadRouter);
app.use('/api/reels',         reelsRouter);
app.use('/api/payments',      paymentsRouter);
app.use('/api/push',          pushRouter);

// ── Socket.io ────────────────────────────────────────────────────────────────
initSocket(server);

// ── Error handler ─────────────────────────────────────────────────────────────
import { startAutoExpireJob } from './jobs/autoExpire';

app.use(errorHandler);

const PORT = Number(process.env.PORT) || 3000;
server.listen(PORT, '0.0.0.0', () => {
  logger.info(`🚀 GogoMarket API running on :${PORT}`);
  startAutoExpireJob();
});

export default app;
