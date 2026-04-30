import { getTrustRepository } from './repositories/trust.repository.js';

export async function createTrustRequest(vendorId: string, userId: string) {
  return getTrustRepository().createRequest(vendorId, userId);
}

export async function listPendingTrustRequests(vendorUserId: string) {
  return getTrustRepository().listPendingForVendorUser(vendorUserId);
}

export async function reviewTrustRequest(
  vendorId: string,
  userId: string,
  status: string,
  vendorUserId: string,
) {
  return getTrustRepository().reviewByVendorUser(vendorId, userId, status, vendorUserId);
}
