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
import chatsRouter        from './routes/chats';
import sellersRouter      from './routes/sellers';
import deliveryRouter     from './routes/delivery';
import notificationsRouter from './routes/notifications';
import adminRouter        from './routes/admin';
import uploadRouter       from './routes/upload';

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
app.use('/auth',          authRouter);
app.use('/feed',          feedRouter);
app.use('/products',      productsRouter);
app.use('/orders',        ordersRouter);
app.use('/chats',         chatsRouter);
app.use('/sellers',       sellersRouter);
app.use('/delivery',      deliveryRouter);
app.use('/notifications', notificationsRouter);
app.use('/admin',         adminRouter);
app.use('/upload',        uploadRouter);

// ── Socket.io ────────────────────────────────────────────────────────────────
initSocket(server);

// ── Error handler ─────────────────────────────────────────────────────────────
app.use(errorHandler);

const PORT = Number(process.env.PORT) || 3000;
server.listen(PORT, '0.0.0.0', () => {
  logger.info(`🚀 GogoMarket API running on :${PORT}`);
});

export default app;
