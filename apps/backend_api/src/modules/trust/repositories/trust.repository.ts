import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import { presentTrust } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { getTrust, listTrusts, saveTrust } from '../../../shared/dev-store.js';
import { buildStubTrust } from '../../../shared/stub-data.js';

export interface TrustRepository {
  createRequest(vendorId: string, userId: string): Promise<Record<string, unknown>>;
  listPendingForVendorUser(
    vendorUserId: string,
  ): Promise<{ trusts?: Record<string, unknown>[]; error?: 'forbidden' }>;
  reviewByVendorUser(
    vendorId: string,
    userId: string,
    status: string,
    vendorUserId: string,
  ): Promise<{ trust?: Record<string, unknown>; error?: 'forbidden' }>;
  getTrust(vendorId: string, userId: string): Promise<Record<string, unknown> | null>;
}

class DevStoreTrustRepository implements TrustRepository {
  async createRequest(vendorId: string, userId: string) {
    const trust = buildStubTrust({
      vendorId,
      userId,
      status: 'pending',
    });
    saveTrust(trust);
    return trust;
  }

  async listPendingForVendorUser(vendorUserId: string) {
    return {
      trusts: listTrusts().filter(
        (item) => item.status === 'pending' && item.vendorId === buildStubTrust().vendorId && vendorUserId === 'user-vendor',
      ),
    };
  }

  async reviewByVendorUser(vendorId: string, userId: string, status: string, vendorUserId: string) {
    if (vendorUserId !== 'user-vendor' || vendorId !== buildStubTrust().vendorId) {
      return { error: 'forbidden' as const };
    }
    const currentTrust = getTrust(vendorId, userId);
    const updatedTrust = buildStubTrust({
      ...(currentTrust ?? {}),
      vendorId,
      userId,
      status,
      reviewedAt: new Date().toISOString(),
    });
    saveTrust(updatedTrust);
    return { trust: updatedTrust };
  }

  async getTrust(vendorId: string, userId: string) {
    return getTrust(vendorId, userId);
  }
}

class PrismaTrustRepository implements TrustRepository {
  async createRequest(vendorId: string, userId: string) {
    await ensureDemoData();
    const trust = await prisma.trustRelationship.upsert({
      where: {
        vendorId_userId: {
          vendorId,
          userId,
        },
      },
      update: {
        status: 'PENDING',
        reviewedAt: null,
        reviewReason: null,
      },
      create: {
        vendorId,
        userId,
        status: 'PENDING',
      },
    });
    return presentTrust(trust);
  }

  async listPendingForVendorUser(vendorUserId: string) {
    await ensureDemoData();
    const vendor = await prisma.vendorProfile.findUnique({
      where: { userId: vendorUserId },
      select: { id: true },
    });
    if (!vendor) {
      return { error: 'forbidden' as const };
    }
    const trusts = await prisma.trustRelationship.findMany({
      where: {
        status: 'PENDING',
        vendorId: vendor.id,
      },
      orderBy: { requestedAt: 'asc' },
    });
    return { trusts: trusts.map((trust: (typeof trusts)[number]) => presentTrust(trust)) };
  }

  async reviewByVendorUser(vendorId: string, userId: string, status: string, vendorUserId: string) {
    await ensureDemoData();
    const vendor = await prisma.vendorProfile.findUnique({
      where: { userId: vendorUserId },
      select: { id: true },
    });
    if (!vendor || vendor.id !== vendorId) {
      return { error: 'forbidden' as const };
    }
    const trust = await prisma.trustRelationship.upsert({
      where: {
        vendorId_userId: {
          vendorId,
          userId,
        },
      },
      update: {
        status: status.toUpperCase() as 'PENDING' | 'APPROVED' | 'BLOCKED',
        reviewedAt: new Date(),
      },
      create: {
        vendorId,
        userId,
        status: status.toUpperCase() as 'PENDING' | 'APPROVED' | 'BLOCKED',
        reviewedAt: new Date(),
      },
    });
    return { trust: presentTrust(trust) };
  }

  async getTrust(vendorId: string, userId: string) {
    await ensureDemoData();
    const trust = await prisma.trustRelationship.findUnique({
      where: {
        vendorId_userId: {
          vendorId,
          userId,
        },
      },
    });
    return trust ? presentTrust(trust) : null;
  }
}

export function getTrustRepository(): TrustRepository {
  return env.PERSISTENCE_MODE === 'prisma'
    ? new PrismaTrustRepository()
    : new DevStoreTrustRepository();
}
