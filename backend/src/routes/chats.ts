import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { chats, messages, sellers } from '../db/schema';
import { authenticate } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { eq, and, or, desc } from 'drizzle-orm';

const router = Router();

// GET /v1/chats — list my chats
router.get('/', authenticate, async (req, res) => {
  const userId = req.user!.userId;
  const [seller] = await db.select().from(sellers).where(eq(sellers.userId, userId)).limit(1);

  const userChats = await db.select().from(chats).where(
    seller
      ? or(eq(chats.buyerId, userId), eq(chats.sellerId, seller.id))
      : eq(chats.buyerId, userId)
  ).orderBy(desc(chats.lastMessageAt)).limit(50);

  res.json(userChats);
});

// POST /v1/chats — create or get chat with seller
router.post('/', authenticate, async (req, res) => {
  const { sellerId } = z.object({ sellerId: z.string().uuid() }).parse(req.body);
  const buyerId = req.user!.userId;

  let [chat] = await db.select().from(chats)
    .where(and(eq(chats.buyerId, buyerId), eq(chats.sellerId, sellerId))).limit(1);

  if (!chat) {
    [chat] = await db.insert(chats).values({ buyerId, sellerId }).returning();
  }

  res.json(chat);
});

// GET /v1/chats/:id/messages
router.get('/:id/messages', authenticate, async (req, res) => {
  const q = z.object({
    before: z.string().optional(), // cursor-based pagination
    limit:  z.coerce.number().max(50).default(30),
  }).parse(req.query);

  const chatId = req.params['id'] as string;
  const msgs = await db.select().from(messages)
    .where(eq(messages.chatId, chatId))
    .orderBy(desc(messages.createdAt))
    .limit(q.limit);

  res.json(msgs.reverse()); // chronological order
});

// POST /v1/chats/:id/messages (REST fallback, prefer WebSocket)
router.post('/:id/messages', authenticate, async (req, res) => {
  const chatId = req.params['id'] as string;
  const body = z.object({
    type:    z.enum(['text', 'image', 'audio', 'offer']).default('text'),
    content: z.string().max(4000).optional(),
    mediaUrl: z.string().url().optional(),
    offerProductId: z.string().uuid().optional(),
  }).parse(req.body);

  const [msg] = await db.insert(messages).values({
    chatId,
    senderId: req.user!.userId,
    type:     body.type,
    content:  body.content,
    mediaUrl: body.mediaUrl,
    offerProductId: body.offerProductId,
  }).returning();

  await db.update(chats).set({ lastMessageAt: new Date() }).where(eq(chats.id, chatId));

  res.status(201).json(msg);
});

export default router;
