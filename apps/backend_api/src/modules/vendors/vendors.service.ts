import { getVendorsRepository } from './repositories/vendors.repository.js';

export async function getVendorForUser(vendorId: string, userId: string) {
  return getVendorsRepository().getForUser(vendorId, userId);
}
