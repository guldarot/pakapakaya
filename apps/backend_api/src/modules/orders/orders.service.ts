import { getStorageService } from '../../shared/storage/storage.service.js';
import { getOrdersRepository } from './repositories/orders.repository.js';

export async function listOrdersForBuyer(userId: string) {
  return getOrdersRepository().listForBuyer(userId);
}

export async function listOrdersForVendorUser(vendorUserId: string) {
  return getOrdersRepository().listForVendorUser(vendorUserId);
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

export async function getOrderForParticipant(orderId: string, userId: string) {
  return getOrdersRepository().getForParticipant(orderId, userId);
}

export async function preparePaymentProofUploadForBuyer(input: {
  orderId: string;
  buyerId: string;
  fileName: string;
  contentType: string;
}) {
  const result = await getOrdersRepository().getForBuyer(input.orderId, input.buyerId);
  if ('error' in result) {
    return result;
  }

  const safeFileName = input.fileName.replace(/[^a-zA-Z0-9._-]/g, '-');
  const assetKey = `orders/${input.orderId}/payment-proof/${safeFileName}`;
  const storage = getStorageService();

  return {
    upload: storage.prepareTextUpload(
      assetKey,
      `Prepared payment-proof upload for order ${input.orderId}`,
      input.contentType,
    ),
  };
}

export async function uploadPaymentProofForBuyer(orderId: string, buyerId: string, assetPath: string) {
  return getOrdersRepository().uploadPaymentProofForBuyer(orderId, buyerId, assetPath);
}

export async function updateOrderStatusForVendorUser(input: {
  orderId: string;
  vendorUserId: string;
  nextStatus: 'confirmed' | 'ready' | 'completed';
}) {
  return getOrdersRepository().updateStatusForVendorUser(input);
}
