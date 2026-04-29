import { getOrdersRepository } from './repositories/orders.repository.js';

export async function listOrdersForBuyer(userId: string) {
  return getOrdersRepository().listForBuyer(userId);
}

export async function createOrderForBuyer(input: {
  buyerId: string;
  batchId: string;
  quantity: number;
  logisticsMode: 'pickup' | 'delivery';
  isByob: boolean;
}) {
  return getOrdersRepository().createForBuyer(input);
}

export async function getOrderForBuyer(orderId: string, buyerId: string) {
  return getOrdersRepository().getForBuyer(orderId, buyerId);
}

export async function uploadPaymentProofForBuyer(orderId: string, buyerId: string, assetPath: string) {
  return getOrdersRepository().uploadPaymentProofForBuyer(orderId, buyerId, assetPath);
}
