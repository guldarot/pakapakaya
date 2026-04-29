import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import { presentVendorProfile } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { buildStubVendor } from '../../../shared/stub-data.js';
import { getTrustRepository } from '../../trust/repositories/trust.repository.js';

export interface DiscoveryRepository {
  listForUser(userId: string, radiusKm: number): Promise<Record<string, unknown>[]>;
}

class DevStoreDiscoveryRepository implements DiscoveryRepository {
  async listForUser(userId: string, radiusKm: number) {
    const trust = await getTrustRepository().getTrust('vendor-1', userId);
    return [
      buildStubVendor({
        trustStatus: trust?.status ?? 'pending',
        fuzzedDistanceKm: Math.min(radiusKm, 1),
      }),
    ];
  }
}

class PrismaDiscoveryRepository implements DiscoveryRepository {
  async listForUser(userId: string, radiusKm: number) {
    await ensureDemoData();
    const vendors = await prisma.vendorProfile.findMany({
      include: {
        user: true,
        paymentMethods: true,
        inventoryItems: true,
      },
      orderBy: { createdAt: 'asc' },
    });
    const batchesByVendor = await prisma.batch.findMany({
      where: {
        item: {
          vendorId: { in: vendors.map((vendor: (typeof vendors)[number]) => vendor.id) },
        },
      },
      include: {
        item: true,
      },
    });
    const trusts = await prisma.trustRelationship.findMany({
      where: {
        userId,
        vendorId: { in: vendors.map((vendor: (typeof vendors)[number]) => vendor.id) },
      },
    });

    return vendors.map((vendor: (typeof vendors)[number]) =>
      presentVendorProfile(
        {
          ...vendor,
          batches: batchesByVendor.filter(
            (batch: (typeof batchesByVendor)[number]) => batch.item.vendorId === vendor.id,
          ),
        },
        {
          trustStatus:
            trusts.find((trust: (typeof trusts)[number]) => trust.vendorId === vendor.id)
              ?.status ?? 'PENDING',
          fuzzedDistanceKm: Math.min(radiusKm, 1),
        },
      ),
    );
  }
}

export function getDiscoveryRepository(): DiscoveryRepository {
  return env.PERSISTENCE_MODE === 'prisma'
    ? new PrismaDiscoveryRepository()
    : new DevStoreDiscoveryRepository();
}
