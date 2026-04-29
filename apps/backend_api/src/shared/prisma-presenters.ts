import { mapDeliveryMode, mapOrderStatus, mapPaymentStatus } from './demo-bootstrap.js';

function lowerCaseEnum(value: string) {
  return value.toLowerCase();
}

function formatIso(value: Date | null | undefined) {
  return value?.toISOString() ?? null;
}

export function presentUser(user: {
  id: string;
  phone: string;
  name: string;
  imageUrl: string | null;
  role: string;
  status: string;
  trustScore: number;
  codStrikeCount: number;
  createdAt: Date;
  updatedAt: Date;
}) {
  return {
    id: user.id,
    phone: user.phone,
    name: user.name,
    imageUrl: user.imageUrl,
    role: lowerCaseEnum(user.role),
    status: lowerCaseEnum(user.status),
    trustScore: user.trustScore,
    codStrikeCount: user.codStrikeCount,
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
  };
}

export function presentBatch(
  batch: {
    id: string;
    itemId: string;
    availableFrom: Date;
    availableUntil: Date;
    cutoffTime: Date;
    maxQuantity: number;
    remainingQuantity: number;
    status: string;
    acceptOrdersDuringPrep: boolean;
    createdAt: Date;
    updatedAt: Date;
  } & {
    item?: {
      id: string;
      vendorId: string;
      name: string;
      description: string;
      imageUrl: string | null;
      basePrice: number;
      isActive: boolean;
      category: string;
      createdAt: Date;
      updatedAt: Date;
    };
  },
) {
  return {
    id: batch.id,
    itemId: batch.itemId,
    availableFrom: batch.availableFrom.toISOString(),
    availableUntil: batch.availableUntil.toISOString(),
    cutoffTime: batch.cutoffTime.toISOString(),
    maxQuantity: batch.maxQuantity,
    remainingQuantity: batch.remainingQuantity,
    status: lowerCaseEnum(batch.status),
    acceptOrdersDuringPrep: batch.acceptOrdersDuringPrep,
    createdAt: batch.createdAt.toISOString(),
    updatedAt: batch.updatedAt.toISOString(),
    item: batch.item
      ? {
          id: batch.item.id,
          vendorId: batch.item.vendorId,
          name: batch.item.name,
          description: batch.item.description,
          imageUrl: batch.item.imageUrl,
          basePrice: batch.item.basePrice,
          isActive: batch.item.isActive,
          category: batch.item.category,
          createdAt: batch.item.createdAt.toISOString(),
          updatedAt: batch.item.updatedAt.toISOString(),
        }
      : undefined,
  };
}

export function presentVendorProfile(
  vendor: {
    id: string;
    userId: string;
    storeName: string;
    bio: string;
    status: string;
    customStatus: string | null;
    subscriptionTier: string;
    packagingCost: number;
    monthlyOrderCount: number;
    billingCycleStart: Date;
    verifiedBadge: boolean;
    createdAt: Date;
    updatedAt: Date;
    user: {
      id: string;
      phone: string;
      name: string;
      imageUrl: string | null;
      role: string;
      status: string;
      trustScore: number;
      codStrikeCount: number;
      createdAt: Date;
      updatedAt: Date;
    };
    paymentMethods?: Array<{
      id: string;
      type: string;
      label: string;
      accountName: string;
      maskedAccount: string;
      instructions: string;
      isActive: boolean;
      createdAt: Date;
      updatedAt: Date;
    }>;
    inventoryItems?: Array<{
      id: string;
      vendorId: string;
      name: string;
      description: string;
      imageUrl: string | null;
      basePrice: number;
      isActive: boolean;
      category: string;
      createdAt: Date;
      updatedAt: Date;
    }>;
  } & {
    batches?: Array<{
      id: string;
      itemId: string;
      availableFrom: Date;
      availableUntil: Date;
      cutoffTime: Date;
      maxQuantity: number;
      remainingQuantity: number;
      status: string;
      acceptOrdersDuringPrep: boolean;
      createdAt: Date;
      updatedAt: Date;
      item?: {
        id: string;
        vendorId: string;
        name: string;
        description: string;
        imageUrl: string | null;
        basePrice: number;
        isActive: boolean;
        category: string;
        createdAt: Date;
        updatedAt: Date;
      };
    }>;
  },
  options?: {
    trustStatus?: string | null;
    fuzzedDistanceKm?: number;
  },
) {
  return {
    id: vendor.id,
    userId: vendor.userId,
    storeName: vendor.storeName,
    bio: vendor.bio,
    status: lowerCaseEnum(vendor.status),
    subscriptionTier: lowerCaseEnum(vendor.subscriptionTier),
    packagingCost: vendor.packagingCost,
    deliveryModes: ['pickup'],
    monthlyOrderCount: vendor.monthlyOrderCount,
    billingCycleStart: vendor.billingCycleStart.toISOString(),
    verifiedBadge: vendor.verifiedBadge,
    customStatus: vendor.customStatus,
    paymentMethods: (vendor.paymentMethods ?? []).map((method) => ({
      id: method.id,
      vendorId: vendor.id,
      type: lowerCaseEnum(method.type),
      label: method.label,
      accountName: method.accountName,
      maskedAccount: method.maskedAccount,
      instructions: method.instructions,
      isActive: method.isActive,
      createdAt: method.createdAt.toISOString(),
      updatedAt: method.updatedAt.toISOString(),
    })),
    user: presentUser(vendor.user),
    trustStatus: options?.trustStatus ? lowerCaseEnum(String(options.trustStatus)) : 'pending',
    fuzzedDistanceKm: options?.fuzzedDistanceKm ?? 0.8,
    inventoryItems: (vendor.inventoryItems ?? []).map((item) => ({
      id: item.id,
      vendorId: item.vendorId,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      basePrice: item.basePrice,
      isActive: item.isActive,
      category: item.category,
      createdAt: item.createdAt.toISOString(),
      updatedAt: item.updatedAt.toISOString(),
    })),
    batches: (vendor.batches ?? []).map((batch) => presentBatch(batch)),
  };
}

export function presentOrder(
  order: {
    id: string;
    batchId: string;
    buyerId: string;
    vendorId: string;
    status: string;
    logisticsMode: string;
    isByob: boolean;
    quantity: number;
    unitPriceSnapshot: number;
    packagingFeeSnapshot: number;
    totalAmount: number;
    paymentStatus: string;
    paymentScreenshotUrl: string | null;
    createdAt: Date;
    updatedAt: Date;
    batch?: {
      id: string;
      itemId: string;
      availableFrom: Date;
      availableUntil: Date;
      cutoffTime: Date;
      maxQuantity: number;
      remainingQuantity: number;
      status: string;
      acceptOrdersDuringPrep: boolean;
      createdAt: Date;
      updatedAt: Date;
      item?: {
        id: string;
        vendorId: string;
        name: string;
        description: string;
        imageUrl: string | null;
        basePrice: number;
        isActive: boolean;
        category: string;
        createdAt: Date;
        updatedAt: Date;
      };
    };
  },
) {
  return {
    id: order.id,
    batchId: order.batchId,
    buyerId: order.buyerId,
    vendorId: order.vendorId,
    status: mapOrderStatus(order.status),
    logisticsMode: mapDeliveryMode(order.logisticsMode),
    isByob: order.isByob,
    quantity: order.quantity,
    unitPriceSnapshot: order.unitPriceSnapshot,
    packagingFeeSnapshot: order.packagingFeeSnapshot,
    totalAmount: order.totalAmount,
    paymentStatus: mapPaymentStatus(order.paymentStatus),
    paymentScreenshotUrl: order.paymentScreenshotUrl,
    createdAt: order.createdAt.toISOString(),
    updatedAt: order.updatedAt.toISOString(),
    batch: order.batch ? presentBatch(order.batch) : undefined,
  };
}

export function presentMessage(message: {
  id: string;
  roomId: string;
  senderId: string;
  type: string;
  content: string;
  metadata: unknown;
  deliveryState: string;
  createdAt: Date;
}) {
  return {
    id: message.id,
    roomId: message.roomId,
    senderId: message.senderId,
    type: lowerCaseEnum(message.type),
    content: message.content,
    metadata: (message.metadata ?? {}) as Record<string, unknown>,
    deliveryState: lowerCaseEnum(message.deliveryState),
    createdAt: message.createdAt.toISOString(),
  };
}

export function presentTrust(trust: {
  vendorId: string;
  userId: string;
  status: string;
  requestedAt: Date;
  reviewedAt: Date | null;
  reviewReason: string | null;
}) {
  return {
    vendorId: trust.vendorId,
    userId: trust.userId,
    status: lowerCaseEnum(trust.status),
    requestedAt: trust.requestedAt.toISOString(),
    reviewedAt: formatIso(trust.reviewedAt),
    reviewReason: trust.reviewReason,
  };
}
