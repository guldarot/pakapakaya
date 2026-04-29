import '../models/models.dart';
import 'mock_data.dart';

class MockBackend {
  MockBackend._();

  static final MockBackend instance = MockBackend._();

  AppUser? _currentUser;
  final List<VendorProfile> _vendors = List.of(MockData.vendors);
  final List<Order> _orders = [];
  final Map<String, ChatRoom> _roomsByOrderId = {};
  final Map<String, List<ChatMessage>> _messagesByRoomId = {};
  final List<TrustRelationship> _trustRelationships = [
    ...MockData.initialTrusts,
  ];

  AppUser? get currentUserOrNull => _currentUser;

  AppUser get currentUser {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Not authenticated.');
    }
    return user;
  }

  Future<AppUser> loginWithOtp(OtpLoginRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentUser = MockData.buyerUser;
    return currentUser;
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    return MockData.plans;
  }

  Future<List<VendorProfile>> getDiscoveryVendors({required int radiusKm}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return _vendors
        .where((vendor) => vendor.fuzzedDistanceKm <= radiusKm + 0.99)
        .map(_attachTrustStatus)
        .toList();
  }

  Future<VendorProfile> getVendor(String vendorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _attachTrustStatus(
      _vendors.firstWhere((vendor) => vendor.id == vendorId),
    );
  }

  Future<TrustRelationship> requestTrust(String vendorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final existingIndex = _trustRelationships.indexWhere(
      (item) => item.vendorId == vendorId && item.userId == currentUser.id,
    );

    final relationship = TrustRelationship(
      vendorId: vendorId,
      userId: currentUser.id,
      status: TrustStatus.pending,
      requestedAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _trustRelationships[existingIndex] = relationship;
    } else {
      _trustRelationships.add(relationship);
    }

    return relationship;
  }

  Future<List<TrustRelationship>> getVendorTrustRequests() async {
    return _trustRelationships
        .where((relationship) => relationship.status == TrustStatus.pending)
        .toList();
  }

  Future<void> approveTrust({
    required String vendorId,
    required String userId,
    required TrustStatus status,
  }) async {
    final index = _trustRelationships.indexWhere(
      (item) => item.vendorId == vendorId && item.userId == userId,
    );
    if (index >= 0) {
      final current = _trustRelationships[index];
      _trustRelationships[index] = TrustRelationship(
        vendorId: current.vendorId,
        userId: current.userId,
        status: status,
        requestedAt: current.requestedAt,
        reviewedAt: DateTime.now(),
        reviewReason: status == TrustStatus.blocked ? 'Blocked by vendor' : null,
      );
    }
  }

  Future<Order> createOrder(CreateOrderRequestDto request) async {
    final vendor = _vendors.firstWhere(
      (item) => item.batches.any((batch) => batch.id == request.batchId),
    );
    final batch = vendor.batches.firstWhere((item) => item.id == request.batchId);

    if (_trustStatusForVendor(vendor.id) != TrustStatus.approved) {
      throw StateError('Vendor approval required before ordering.');
    }

    if (batch.remainingQuantity < request.quantity) {
      throw StateError('Not enough remaining quantity for this batch.');
    }

    final packagingFee = request.isByob ? 0.0 : vendor.packagingCost;
    final totalAmount =
        (batch.item.basePrice * request.quantity) + (packagingFee * request.quantity);

    final updatedBatch = Batch(
      id: batch.id,
      itemId: batch.itemId,
      availableFrom: batch.availableFrom,
      availableUntil: batch.availableUntil,
      cutoffTime: batch.cutoffTime,
      maxQuantity: batch.maxQuantity,
      remainingQuantity: batch.remainingQuantity - request.quantity,
      status: batch.status,
      acceptOrdersDuringPrep: batch.acceptOrdersDuringPrep,
      createdAt: batch.createdAt,
      updatedAt: DateTime.now(),
      item: batch.item,
    );

    final updatedVendor = VendorProfile(
      id: vendor.id,
      userId: vendor.userId,
      storeName: vendor.storeName,
      bio: vendor.bio,
      status: vendor.status,
      subscriptionTier: vendor.subscriptionTier,
      packagingCost: vendor.packagingCost,
      deliveryModes: vendor.deliveryModes,
      monthlyOrderCount: vendor.monthlyOrderCount + 1,
      billingCycleStart: vendor.billingCycleStart,
      verifiedBadge: vendor.verifiedBadge,
      paymentMethods: vendor.paymentMethods,
      user: vendor.user,
      trustStatus: _trustStatusForVendor(vendor.id),
      fuzzedDistanceKm: vendor.fuzzedDistanceKm,
      inventoryItems: vendor.inventoryItems,
      batches: vendor.batches
          .map((existingBatch) => existingBatch.id == batch.id ? updatedBatch : existingBatch)
          .toList(),
      customStatus: vendor.customStatus,
    );
    _replaceVendor(updatedVendor);

    final order = Order(
      id: 'order-${_orders.length + 1}',
      batchId: updatedBatch.id,
      buyerId: currentUser.id,
      vendorId: vendor.id,
      status: OrderStatus.pendingPayment,
      logisticsMode: request.logisticsMode,
      isByob: request.isByob,
      quantity: request.quantity,
      unitPriceSnapshot: updatedBatch.item.basePrice,
      packagingFeeSnapshot: packagingFee,
      totalAmount: totalAmount,
      paymentStatus: PaymentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      batch: updatedBatch,
    );

    _orders.add(order);

    final room = ChatRoom(
      id: 'room-${order.id}',
      orderId: order.id,
      vendorId: vendor.id,
      buyerId: currentUser.id,
      isBlocked: false,
      lastMessageAt: DateTime.now(),
    );
    _roomsByOrderId[order.id] = room;
    _messagesByRoomId[room.id] = [
      ChatMessage(
        id: 'message-${order.id}-1',
        roomId: room.id,
        senderId: vendor.user.id,
        type: MessageType.system,
        content: 'Order created. Upload payment proof to continue.',
        deliveryState: MessageDeliveryState.delivered,
        createdAt: DateTime.now(),
      ),
    ];

    return order;
  }

  Future<List<Order>> getOrders() async => List.of(_orders);

  Future<Order> getOrder(String orderId) async {
    return _orders.firstWhere((order) => order.id == orderId);
  }

  Future<String> getRoomIdForOrder(String orderId) async {
    final room = _roomsByOrderId[orderId];
    if (room == null) {
      throw StateError('Room not found for order $orderId.');
    }
    return room.id;
  }

  Future<Order> uploadPaymentProof({
    required String orderId,
    required String assetPath,
  }) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    final current = _orders[index];
    final updated = Order(
      id: current.id,
      batchId: current.batchId,
      buyerId: current.buyerId,
      vendorId: current.vendorId,
      status: OrderStatus.verification,
      logisticsMode: current.logisticsMode,
      isByob: current.isByob,
      quantity: current.quantity,
      unitPriceSnapshot: current.unitPriceSnapshot,
      packagingFeeSnapshot: current.packagingFeeSnapshot,
      totalAmount: current.totalAmount,
      paymentStatus: PaymentStatus.uploaded,
      paymentScreenshotUrl: assetPath,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      batch: current.batch,
      deliveryAddressSnapshot: current.deliveryAddressSnapshot,
    );
    _orders[index] = updated;
    return updated;
  }

  Future<List<ChatMessage>> getMessages(String orderId) async {
    final room = _roomsByOrderId[orderId];
    if (room == null) {
      return [];
    }
    return List.of(_messagesByRoomId[room.id] ?? const []);
  }

  Future<ChatMessage> sendMessage(SendMessageRequestDto request) async {
    final messages = _messagesByRoomId[request.roomId];
    if (messages == null) {
      throw StateError('Room not found.');
    }

    final message = ChatMessage(
      id: 'message-${messages.length + 1}',
      roomId: request.roomId,
      senderId: currentUser.id,
      type: request.type,
      content: request.content,
      metadata: request.metadata,
      deliveryState: MessageDeliveryState.sent,
      createdAt: DateTime.now(),
    );
    messages.add(message);
    return message;
  }

  TrustStatus _trustStatusForVendor(String vendorId) {
    if (_currentUser == null) {
      return TrustStatus.pending;
    }

    final matches = _trustRelationships
        .where((item) => item.vendorId == vendorId && item.userId == currentUser.id)
        .toList();

    if (matches.isEmpty) {
      return TrustStatus.pending;
    }

    return matches.first.status;
  }

  VendorProfile _attachTrustStatus(VendorProfile vendor) {
    return VendorProfile(
      id: vendor.id,
      userId: vendor.userId,
      storeName: vendor.storeName,
      bio: vendor.bio,
      status: vendor.status,
      subscriptionTier: vendor.subscriptionTier,
      packagingCost: vendor.packagingCost,
      deliveryModes: vendor.deliveryModes,
      monthlyOrderCount: vendor.monthlyOrderCount,
      billingCycleStart: vendor.billingCycleStart,
      verifiedBadge: vendor.verifiedBadge,
      paymentMethods: vendor.paymentMethods,
      user: vendor.user,
      trustStatus: _trustStatusForVendor(vendor.id),
      fuzzedDistanceKm: vendor.fuzzedDistanceKm,
      inventoryItems: vendor.inventoryItems,
      batches: vendor.batches,
      customStatus: vendor.customStatus,
    );
  }

  void _replaceVendor(VendorProfile vendor) {
    final index = _vendors.indexWhere((item) => item.id == vendor.id);
    if (index >= 0) {
      _vendors[index] = vendor;
    }
  }
}
