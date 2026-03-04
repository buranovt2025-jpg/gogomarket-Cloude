import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';
import { logger, httpLogger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { initSocket } from './socket';
import { redis } from './utils/redis';

import authRoutes from './routes/auth';
import productRoutes from './routes/products';
import orderRoutes from './routes/orders';
import chatRoutes from './routes/chats';
import sellerRoutes from './routes/sellers';
import deliveryRoutes from './routes/delivery';
import adminRoutes from './routes/admin';
import notificationRoutes from './routes/notifications';

const app = express();
const httpServer = createServer(app);

app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));
app.use(compression() as any);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(httpLogger);
app.use(rateLimiter);

app.get('/health', async (_req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
  });
});

const API = '/v1';
app.use(`${API}/auth`,          authRoutes);
app.use(`${API}/products`,      productRoutes);
app.use(`${API}/orders`,        orderRoutes);
app.use(`${API}/chats`,         chatRoutes);
app.use(`${API}/sellers`,       sellerRoutes);
app.use(`${API}/delivery`,      deliveryRoutes);
app.use(`${API}/notifications`, notificationRoutes);
app.use(`${API}/admin`,         adminRoutes);

initSocket(httpServer);
app.use(errorHandler);

const PORT = Number(process.env.PORT) || 3000;
httpServer.listen(PORT, () => {
  logger.info(`GogoMarket API running on port ${PORT} [${process.env.NODE_ENV}]`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down...');
  httpServer.close(() => process.exit(0));
});

export default app;
