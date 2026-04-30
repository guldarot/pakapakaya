import { getChatRepository } from './repositories/chat.repository.js';

export async function listMessagesForParticipant(orderId: string, userId: string) {
  return getChatRepository().listForParticipant(orderId, userId);
}

export async function sendMessageForParticipant(input: {
  orderId: string;
  userId: string;
  type: 'text' | 'image' | 'audio' | 'offer' | 'system';
  content: string;
  metadata?: Record<string, unknown>;
}) {
  return getChatRepository().sendForParticipant(input);
}
