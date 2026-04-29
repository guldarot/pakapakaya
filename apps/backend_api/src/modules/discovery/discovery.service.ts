import { getDiscoveryRepository } from './repositories/discovery.repository.js';

export async function listDiscoveryVendorsForUser(userId: string, radiusKm: number) {
  return getDiscoveryRepository().listForUser(userId, radiusKm);
}
