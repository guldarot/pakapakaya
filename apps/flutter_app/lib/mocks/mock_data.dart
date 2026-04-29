import '../models/models.dart';

class MockData {
  static final buyerUser = AppUser(
    id: 'user-buyer',
    phone: '+923001234567',
    name: 'Areeba',
    role: UserRole.user,
    status: UserStatus.active,
    trustScore: 92,
    codStrikeCount: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 4, 27),
    locationPoint: const GeoPoint(latitude: 24.9324, longitude: 67.1107),
  );

  static final vendorUser = AppUser(
    id: 'user-vendor',
    phone: '+923009876543',
    name: 'Hina',
    role: UserRole.vendor,
    status: UserStatus.active,
    trustScore: 98,
    codStrikeCount: 0,
    createdAt: DateTime(2026, 1, 10),
    updatedAt: DateTime(2026, 4, 27),
    locationPoint: const GeoPoint(latitude: 24.9310, longitude: 67.1090),
  );

  static final adminUser = AppUser(
    id: 'user-admin',
    phone: '+923112220000',
    name: 'Admin',
    role: UserRole.admin,
    status: UserStatus.active,
    trustScore: 100,
    codStrikeCount: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 4, 27),
  );

  static final plans = [
    const SubscriptionPlan(
      code: SubscriptionTier.free,
      maxInventoryItems: 1,
      maxMonthlyOrders: 10,
      features: ['Single active item', 'Manual payment flow', 'Trust discovery'],
    ),
    const SubscriptionPlan(
      code: SubscriptionTier.standard,
      maxInventoryItems: 5,
      maxMonthlyOrders: 50,
      features: ['Five active items', 'Custom offers', 'Priority discovery'],
    ),
    const SubscriptionPlan(
      code: SubscriptionTier.pro,
      maxInventoryItems: 999,
      maxMonthlyOrders: 999,
      features: ['Unlimited menu', 'Analytics', 'Verified badge'],
    ),
  ];

  static final paymentMethods = [
    const PaymentMethod(
      id: 'pm-1',
      vendorId: 'vendor-1',
      type: PaymentMethodType.easypaisa,
      label: 'EasyPaisa',
      accountName: 'Hina Khan',
      maskedAccount: '03xx-xxxx321',
      instructions: 'Send the amount and upload the screenshot in chat.',
      isActive: true,
    ),
  ];

  static final biryaniItem = InventoryItem(
    id: 'item-1',
    vendorId: 'vendor-1',
    name: 'Chicken Biryani',
    description: 'Home-style biryani with raita and salad.',
    basePrice: 420,
    isActive: true,
    category: 'Lunch',
    createdAt: DateTime(2026, 4, 15),
    updatedAt: DateTime(2026, 4, 27),
  );

  static final batchOne = Batch(
    id: 'batch-1',
    itemId: 'item-1',
    availableFrom: DateTime(2026, 4, 28, 12),
    availableUntil: DateTime(2026, 4, 28, 14),
    cutoffTime: DateTime(2026, 4, 28, 10, 30),
    maxQuantity: 12,
    remainingQuantity: 7,
    status: BatchStatus.open,
    acceptOrdersDuringPrep: false,
    createdAt: DateTime(2026, 4, 27, 7),
    updatedAt: DateTime(2026, 4, 27, 7),
    item: biryaniItem,
  );

  static final vendors = [
    VendorProfile(
      id: 'vendor-1',
      userId: vendorUser.id,
      storeName: 'Hina Kitchen',
      bio: 'Fresh lunch batches for the mohalla. Pickup and BYOB friendly.',
      status: VendorStatus.open,
      subscriptionTier: SubscriptionTier.standard,
      packagingCost: 40,
      deliveryModes: const [DeliveryMode.pickup],
      monthlyOrderCount: 18,
      billingCycleStart: DateTime(2026, 4, 1),
      verifiedBadge: true,
      paymentMethods: paymentMethods,
      user: vendorUser,
      trustStatus: TrustStatus.approved,
      fuzzedDistanceKm: 0.8,
      inventoryItems: [biryaniItem],
      batches: [batchOne],
      customStatus: 'Lunch orders open until 10:30 AM',
    ),
    VendorProfile(
      id: 'vendor-2',
      userId: 'user-vendor-2',
      storeName: 'Dua Dastarkhwan',
      bio: 'Rotating daal and curry menu for nearby families.',
      status: VendorStatus.open,
      subscriptionTier: SubscriptionTier.free,
      packagingCost: 25,
      deliveryModes: const [DeliveryMode.pickup, DeliveryMode.delivery],
      monthlyOrderCount: 5,
      billingCycleStart: DateTime(2026, 4, 1),
      verifiedBadge: false,
      paymentMethods: paymentMethods,
      user: AppUser(
        id: 'user-vendor-2',
        phone: '+923339990000',
        name: 'Dua',
        role: UserRole.vendor,
        status: UserStatus.active,
        trustScore: 87,
        codStrikeCount: 0,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 4, 27),
      ),
      trustStatus: TrustStatus.pending,
      fuzzedDistanceKm: 1.6,
      inventoryItems: [
        InventoryItem(
          id: 'item-2',
          vendorId: 'vendor-2',
          name: 'Daal Chawal',
          description: 'Comfort food, fresh every afternoon.',
          basePrice: 260,
          isActive: true,
          category: 'Lunch',
          createdAt: DateTime(2026, 4, 10),
          updatedAt: DateTime(2026, 4, 20),
        ),
      ],
      batches: [],
    ),
  ];

  static final initialTrusts = [
    TrustRelationship(
      vendorId: 'vendor-1',
      userId: buyerUser.id,
      status: TrustStatus.approved,
      requestedAt: DateTime(2026, 4, 1),
      reviewedAt: DateTime(2026, 4, 1, 12),
    ),
    TrustRelationship(
      vendorId: 'vendor-2',
      userId: buyerUser.id,
      status: TrustStatus.pending,
      requestedAt: DateTime(2026, 4, 26),
    ),
  ];
}
