import { getTrustRepository } from './repositories/trust.repository.js';

export async function createTrustRequest(vendorId: string, userId: string) {
  return getTrustRepository().createRequest(vendorId, userId);
}

export async function listPendingTrustRequests() {
  return getTrustRepository().listPending();
}

export async function reviewTrustRequest(vendorId: string, userId: string, status: string) {
  return getTrustRepository().review(vendorId, userId, status);
}
