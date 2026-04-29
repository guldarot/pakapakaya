import { getChatRepository } from './repositories/chat.repository.js';

export async function listMessagesForBuyer(orderId: string, buyerId: string) {
  return getChatRepository().listForBuyer(orderId, buyerId);
}

export async function sendMessageForBuyer(input: {
  orderId: string;
  buyerId: string;
  type: 'text' | 'image' | 'audio' | 'offer' | 'system';
  content: string;
  metadata?: Record<string, unknown>;
}) {
  return getChatRepository().sendForBuyer(input);
}
