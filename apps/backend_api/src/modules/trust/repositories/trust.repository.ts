import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import { presentTrust } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { getTrust, listTrusts, saveTrust } from '../../../shared/dev-store.js';
import { buildStubTrust } from '../../../shared/stub-data.js';

export interface TrustRepository {
  createRequest(vendorId: string, userId: string): Promise<Record<string, unknown>>;
  listPending(): Promise<Record<string, unknown>[]>;
  review(vendorId: string, userId: string, status: string): Promise<Record<string, unknown>>;
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

  async listPending() {
    return listTrusts().filter((item) => item.status === 'pending');
  }

  async review(vendorId: string, userId: string, status: string) {
    const currentTrust = getTrust(vendorId, userId);
    const updatedTrust = buildStubTrust({
      ...(currentTrust ?? {}),
      vendorId,
      userId,
      status,
      reviewedAt: new Date().toISOString(),
    });
    saveTrust(updatedTrust);
    return updatedTrust;
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

  async listPending() {
    await ensureDemoData();
    const trusts = await prisma.trustRelationship.findMany({
      where: { status: 'PENDING' },
      orderBy: { requestedAt: 'asc' },
    });
    return trusts.map((trust: (typeof trusts)[number]) => presentTrust(trust));
  }

  async review(vendorId: string, userId: string, status: string) {
    await ensureDemoData();
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
    return presentTrust(trust);
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
