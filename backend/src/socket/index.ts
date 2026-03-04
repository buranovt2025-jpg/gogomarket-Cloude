import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import { verifyAccessToken } from '../utils/jwt';
import { db } from '../db';
import { messages, chats, couriers } from '../db/schema';
import { eq } from 'drizzle-orm';
import { logger } from '../utils/logger';

let io: SocketServer;

export const initSocket = (httpServer: HttpServer) => {
  io = new SocketServer(httpServer, {
    cors: { origin: process.env.ALLOWED_ORIGINS?.split(',') || '*', credentials: true },
    transports: ['websocket', 'polling'],
  });

  // ── Auth middleware ──────────────────────────────
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) return next(new Error('Unauthorized'));
    try {
      (socket as any).user = verifyAccessToken(token as string);
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  // ── Connection ───────────────────────────────────
  io.on('connection', (socket: Socket) => {
    const user = (socket as any).user;
    logger.info({ userId: user.userId, role: user.role }, 'Socket connected');

    // Join personal room for push notifications
    socket.join(`user:${user.userId}`);

    // ── Chat events ──────────────────────────────────
    socket.on('chat:join', (chatId: string) => {
      socket.join(`chat:${chatId}`);
    });

    socket.on('chat:leave', (chatId: string) => {
      socket.leave(`chat:${chatId}`);
    });

    socket.on('chat:message', async (data: {
      chatId: string; type: string; content?: string; mediaUrl?: string;
    }) => {
      try {
        const [msg] = await db.insert(messages).values({
          chatId:   data.chatId,
          senderId: user.userId,
          type:     data.type as any,
          content:  data.content,
          mediaUrl: data.mediaUrl,
        }).returning();

        await db.update(chats)
          .set({ lastMessageAt: new Date() })
          .where(eq(chats.id, data.chatId));

        // Broadcast to chat room
        io.to(`chat:${data.chatId}`).emit('chat:message', msg);
      } catch (err) {
        logger.error({ err }, 'chat:message error');
        socket.emit('chat:error', { message: 'Failed to send message' });
      }
    });

    socket.on('chat:typing', (data: { chatId: string; isTyping: boolean }) => {
      socket.to(`chat:${data.chatId}`).emit('chat:typing', {
        userId: user.userId,
        chatId: data.chatId,
        isTyping: data.isTyping,
      });
    });

    // ── Courier GPS ──────────────────────────────────
    socket.on('courier:location', async (data: {
      orderId: string; lat: number; lng: number; bearing?: number;
    }) => {
      if (user.role !== 'courier') return;

      // Update courier position in DB
      await db.update(couriers)
        .set({ currentLat: data.lat, currentLng: data.lng, lastSeenAt: new Date() })
        .where(eq(couriers.userId, user.userId))
        .catch(() => {});

      // Broadcast to order room (buyer sees it)
      io.to(`order:${data.orderId}`).emit('courier:location', {
        lat:     data.lat,
        lng:     data.lng,
        bearing: data.bearing,
      });
    });

    socket.on('order:subscribe', (orderId: string) => {
      socket.join(`order:${orderId}`);
    });

    socket.on('disconnect', () => {
      logger.info({ userId: user.userId }, 'Socket disconnected');
    });
  });

  logger.info('Socket.io initialized');
  return io;
};

export const getIO = () => io;

// Helper: emit notification to specific user
export const emitNotification = (userId: string, payload: object) => {
  io?.to(`user:${userId}`).emit('notification', payload);
};
