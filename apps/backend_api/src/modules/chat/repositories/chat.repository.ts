import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import { appendMessage, getMessages, getOrder } from '../../../shared/dev-store.js';
import { presentMessage } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { nowIso } from '../../../shared/stub-data.js';

export interface ChatRepository {
  listForBuyer(orderId: string, buyerId: string): Promise<{ messages?: Record<string, unknown>[]; error?: 'not-found' | 'forbidden' }>;
  sendForBuyer(input: {
    orderId: string;
    buyerId: string;
    type: 'text' | 'image' | 'audio' | 'offer' | 'system';
    content: string;
    metadata?: Record<string, unknown>;
  }): Promise<{ message?: Record<string, unknown>; error?: 'not-found' | 'forbidden' }>;
}

class DevStoreChatRepository implements ChatRepository {
  async listForBuyer(orderId: string, buyerId: string) {
    const order = getOrder(orderId);
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };
    return { messages: getMessages(orderId) };
  }

  async sendForBuyer(input: {
    orderId: string;
    buyerId: string;
    type: 'text' | 'image' | 'audio' | 'offer' | 'system';
    content: string;
    metadata?: Record<string, unknown>;
  }) {
    const order = getOrder(input.orderId);
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== input.buyerId) return { error: 'forbidden' as const };

    const message = appendMessage(input.orderId, {
      id: `message-${input.orderId}-${getMessages(input.orderId).length + 1}`,
      roomId: `room-${input.orderId}`,
      senderId: input.buyerId,
      type: input.type,
      content: input.content,
      metadata: input.metadata ?? {},
      deliveryState: 'sent',
      createdAt: nowIso(),
    });

    return { message };
  }
}

class PrismaChatRepository implements ChatRepository {
  async listForBuyer(orderId: string, buyerId: string) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        chatRoom: true,
      },
    });
    if (!order || !order.chatRoom) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };

    const messages = await prisma.message.findMany({
      where: {
        roomId: order.chatRoom.id,
      },
      orderBy: { createdAt: 'asc' },
    });
    return { messages: messages.map((message: (typeof messages)[number]) => presentMessage(message)) };
  }

  async sendForBuyer(input: {
    orderId: string;
    buyerId: string;
    type: 'text' | 'image' | 'audio' | 'offer' | 'system';
    content: string;
    metadata?: Record<string, unknown>;
  }) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: input.orderId },
      include: {
        chatRoom: true,
      },
    });
    if (!order || !order.chatRoom) return { error: 'not-found' as const };
    if (order.buyerId !== input.buyerId) return { error: 'forbidden' as const };

    const message = await prisma.message.create({
      data: {
        roomId: order.chatRoom.id,
        senderId: input.buyerId,
        type: input.type.toUpperCase() as 'TEXT' | 'IMAGE' | 'AUDIO' | 'OFFER' | 'SYSTEM',
        content: input.content,
        metadata: (input.metadata ?? {}) as any,
        deliveryState: 'SENT',
      },
    });

    await prisma.chatRoom.update({
      where: { id: order.chatRoom.id },
      data: {
        lastMessageAt: message.createdAt,
      },
    });

    return { message: presentMessage(message) };
  }
}

export function getChatRepository(): ChatRepository {
  return env.PERSISTENCE_MODE === 'prisma'
    ? new PrismaChatRepository()
    : new DevStoreChatRepository();
}
