export const stubSession = {
  token: 'dev-session-token',
  currentUser: {
    id: 'user-buyer',
    phone: '+923001234567',
    name: 'Areeba',
    role: 'user',
    status: 'active',
    trustScore: 92,
    codStrikeCount: 0,
  },
  availablePlans: [
    {
      code: 'free',
      maxInventoryItems: 1,
      maxMonthlyOrders: 10,
      features: ['Single active item', 'Trust-gated ordering'],
    },
    {
      code: 'standard',
      maxInventoryItems: 5,
      maxMonthlyOrders: 50,
      features: ['Custom offers', 'Priority discovery'],
    },
    {
      code: 'pro',
      maxInventoryItems: 999,
      maxMonthlyOrders: 999,
      features: ['Unlimited menu', 'Analytics'],
    }
  ]
};

export const stubUsers = [
  {
    id: 'user-buyer',
    phone: '+923001234567',
    name: 'Areeba',
    role: 'user',
    status: 'active',
    trustScore: 92,
    codStrikeCount: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: 'user-vendor',
    phone: '+923009876543',
    name: 'Hina',
    role: 'vendor',
    status: 'active',
    trustScore: 98,
    codStrikeCount: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: 'user-admin',
    phone: '+923111110000',
    name: 'Admin',
    role: 'admin',
    status: 'active',
    trustScore: 100,
    codStrikeCount: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

export const nowIso = () => new Date().toISOString();

export const stubInventoryItem = {
  id: 'item-1',
  vendorId: 'vendor-1',
  name: 'Chicken Biryani',
  description: 'Home-style biryani',
  basePrice: 420,
  isActive: true,
  category: 'Lunch',
  createdAt: nowIso(),
  updatedAt: nowIso(),
};

export function buildStubBatch(overrides: Record<string, unknown> = {}) {
  return {
    id: 'batch-1',
    itemId: 'item-1',
    availableFrom: nowIso(),
    availableUntil: nowIso(),
    cutoffTime: nowIso(),
    maxQuantity: 10,
    remainingQuantity: 8,
    status: 'open',
    acceptOrdersDuringPrep: false,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    item: stubInventoryItem,
    ...overrides,
  };
}

export function buildStubOrder(overrides: Record<string, unknown> = {}) {
  return {
    id: 'order-1',
    batchId: 'batch-1',
    buyerId: 'user-buyer',
    vendorId: 'vendor-1',
    status: 'pendingPayment',
    logisticsMode: 'pickup',
    isByob: false,
    quantity: 1,
    unitPriceSnapshot: 420,
    packagingFeeSnapshot: 40,
    totalAmount: 460,
    paymentStatus: 'pending',
    paymentScreenshotUrl: null,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    batch: buildStubBatch(),
    ...overrides,
  };
}

export function buildStubVendor(overrides: Record<string, unknown> = {}) {
  return {
    id: 'vendor-1',
    userId: 'user-vendor',
    storeName: 'Hina Kitchen',
    bio: 'Fresh lunch batches for the mohalla.',
    status: 'open',
    subscriptionTier: 'standard',
    packagingCost: 40,
    deliveryModes: ['pickup'],
    monthlyOrderCount: 18,
    billingCycleStart: nowIso(),
    verifiedBadge: true,
    customStatus: 'Lunch orders open until 10:30 AM',
    paymentMethods: [],
    user: {
      id: 'user-vendor',
      phone: '+923009876543',
      name: 'Hina',
      role: 'vendor',
      status: 'active',
      trustScore: 98,
      codStrikeCount: 0,
      createdAt: nowIso(),
      updatedAt: nowIso(),
    },
    trustStatus: 'approved',
    fuzzedDistanceKm: 0.8,
    inventoryItems: [stubInventoryItem],
    batches: [buildStubBatch()],
    ...overrides,
  };
}

export function buildStubTrust(overrides: Record<string, unknown> = {}) {
  return {
    vendorId: 'vendor-1',
    userId: 'user-buyer',
    status: 'pending',
    requestedAt: nowIso(),
    reviewedAt: null,
    reviewReason: null,
    ...overrides,
  };
}
