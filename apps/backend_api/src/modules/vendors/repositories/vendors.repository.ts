import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import { presentVendorProfile } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { buildStubVendor } from '../../../shared/stub-data.js';
import { getTrustRepository } from '../../trust/repositories/trust.repository.js';

export interface VendorsRepository {
  getForUser(vendorId: string, userId: string): Promise<Record<string, unknown>>;
}

class DevStoreVendorsRepository implements VendorsRepository {
  async getForUser(vendorId: string, userId: string) {
    const trust = await getTrustRepository().getTrust(vendorId, userId);
    return buildStubVendor({
      id: vendorId,
      trustStatus: trust?.status ?? 'pending',
    });
  }
}

class PrismaVendorsRepository implements VendorsRepository {
  async getForUser(vendorId: string, userId: string) {
    await ensureDemoData();
    const vendor = await prisma.vendorProfile.findUniqueOrThrow({
      where: { id: vendorId },
      include: {
        user: true,
        paymentMethods: true,
        inventoryItems: true,
      },
    });
    const batches = await prisma.batch.findMany({
      where: {
        item: {
          vendorId,
        },
      },
      include: {
        item: true,
      },
      orderBy: { availableFrom: 'asc' },
    });
    const trust = await prisma.trustRelationship.findUnique({
      where: {
        vendorId_userId: {
          vendorId,
          userId,
        },
      },
    });

    return presentVendorProfile(
      {
        ...vendor,
        batches,
      },
      {
        trustStatus: trust?.status ?? 'PENDING',
      },
    );
  }
}

export function getVendorsRepository(): VendorsRepository {
  return env.PERSISTENCE_MODE === 'prisma'
    ? new PrismaVendorsRepository()
    : new DevStoreVendorsRepository();
}
