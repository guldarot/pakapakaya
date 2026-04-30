import { prisma } from './prisma.js';

export const demoIds = {
  buyerUser: 'demo-buyer-user',
  vendorUser: 'demo-vendor-user',
  adminUser: 'demo-admin-user',
  vendorProfile: 'demo-vendor-profile',
  inventoryItem: 'demo-item-biryani',
  batch: 'demo-batch-biryani',
};

export async function ensureDemoData() {
  await prisma.user.upsert({
    where: { phone: '+923001234567' },
    update: {
      name: 'Areeba',
      role: 'USER',
      status: 'ACTIVE',
      trustScore: 92,
      codStrikeCount: 0,
    },
    create: {
      id: demoIds.buyerUser,
      phone: '+923001234567',
      name: 'Areeba',
      role: 'USER',
      status: 'ACTIVE',
      trustScore: 92,
      codStrikeCount: 0,
    },
  });

  const vendorUser = await prisma.user.upsert({
    where: { phone: '+923009876543' },
    update: {
      name: 'Hina',
      role: 'VENDOR',
      status: 'ACTIVE',
      trustScore: 98,
      codStrikeCount: 0,
    },
    create: {
      id: demoIds.vendorUser,
      phone: '+923009876543',
      name: 'Hina',
      role: 'VENDOR',
      status: 'ACTIVE',
      trustScore: 98,
      codStrikeCount: 0,
    },
  });

  await prisma.user.upsert({
    where: { phone: '+923111110000' },
    update: {
      name: 'Admin',
      role: 'ADMIN',
      status: 'ACTIVE',
      trustScore: 100,
      codStrikeCount: 0,
    },
    create: {
      id: demoIds.adminUser,
      phone: '+923111110000',
      name: 'Admin',
      role: 'ADMIN',
      status: 'ACTIVE',
      trustScore: 100,
      codStrikeCount: 0,
    },
  });

  await prisma.vendorProfile.upsert({
    where: { userId: vendorUser.id },
    update: {
      storeName: 'Hina Kitchen',
      bio: 'Fresh lunch batches for the mohalla.',
      status: 'OPEN',
      customStatus: 'Lunch orders open until 10:30 AM',
      subscriptionTier: 'STANDARD',
      packagingCost: 40,
      monthlyOrderCount: 18,
      verifiedBadge: true,
    },
    create: {
      id: demoIds.vendorProfile,
      userId: vendorUser.id,
      storeName: 'Hina Kitchen',
      bio: 'Fresh lunch batches for the mohalla.',
      status: 'OPEN',
      customStatus: 'Lunch orders open until 10:30 AM',
      subscriptionTier: 'STANDARD',
      packagingCost: 40,
      monthlyOrderCount: 18,
      verifiedBadge: true,
    },
  });

  await prisma.inventoryItem.upsert({
    where: { id: demoIds.inventoryItem },
    update: {
      vendorId: demoIds.vendorProfile,
      name: 'Chicken Biryani',
      description: 'Home-style biryani',
      basePrice: 420,
      isActive: true,
      category: 'Lunch',
    },
    create: {
      id: demoIds.inventoryItem,
      vendorId: demoIds.vendorProfile,
      name: 'Chicken Biryani',
      description: 'Home-style biryani',
      basePrice: 420,
      isActive: true,
      category: 'Lunch',
    },
  });

  const availableFrom = new Date();
  availableFrom.setHours(12, 0, 0, 0);
  const availableUntil = new Date();
  availableUntil.setHours(14, 0, 0, 0);
  const cutoffTime = new Date();
  cutoffTime.setHours(10, 30, 0, 0);

  await prisma.batch.upsert({
    where: { id: demoIds.batch },
    update: {
      itemId: demoIds.inventoryItem,
      availableFrom,
      availableUntil,
      cutoffTime,
      maxQuantity: 10,
      remainingQuantity: 8,
      status: 'OPEN',
      acceptOrdersDuringPrep: false,
    },
    create: {
      id: demoIds.batch,
      itemId: demoIds.inventoryItem,
      availableFrom,
      availableUntil,
      cutoffTime,
      maxQuantity: 10,
      remainingQuantity: 8,
      status: 'OPEN',
      acceptOrdersDuringPrep: false,
    },
  });

  const buyer = await prisma.user.findUniqueOrThrow({
    where: { phone: '+923001234567' },
  });

  await prisma.trustRelationship.upsert({
    where: {
      vendorId_userId: {
        vendorId: demoIds.vendorProfile,
        userId: buyer.id,
      },
    },
    update: {},
    create: {
      vendorId: demoIds.vendorProfile,
      userId: buyer.id,
      status: 'APPROVED',
    },
  });
}

export async function resetAndSeedDemoData() {
  await prisma.message.deleteMany();
  await prisma.chatRoom.deleteMany();
  await prisma.order.deleteMany();
  await prisma.trustRelationship.deleteMany();
  await prisma.batch.deleteMany();
  await prisma.inventoryItem.deleteMany();
  await prisma.paymentMethod.deleteMany();
  await prisma.vendorProfile.deleteMany();
  await prisma.devSession.deleteMany();
  await prisma.user.deleteMany({
    where: {
      id: {
        in: [demoIds.buyerUser, demoIds.vendorUser, demoIds.adminUser],
      },
    },
  });

  await ensureDemoData();
}

export function mapOrderStatus(orderStatus: string) {
  return orderStatus
    .toLowerCase()
    .replace(/_([a-z])/g, (_: string, char: string) => char.toUpperCase());
}

export function mapPaymentStatus(paymentStatus: string) {
  return paymentStatus.toLowerCase();
}

export function mapDeliveryMode(mode: string) {
  return mode.toLowerCase();
}
