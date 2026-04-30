import '../../mocks/mock_backend.dart';
import '../../models/models.dart';
import 'auth_repository.dart';
import 'chat_repository.dart';
import 'marketplace_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._backend);

  final MockBackend _backend;

  @override
  AppUser? get currentUserOrNull => _backend.currentUserOrNull;

  @override
  Future<AppUser?> restoreSession() => _backend.restoreSession();

  @override
  Future<AppUser> loginDemo(UserRole role) {
    final phone = switch (role) {
      UserRole.user => '+923001234567',
      UserRole.vendor => '+923009876543',
      UserRole.admin => '+923111110000',
    };
    return _backend.loginWithOtp(
      OtpLoginRequestDto(phone: phone, otpCode: '123456'),
    );
  }

  @override
  Future<void> logout() => _backend.logout();
}

class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Order> createOrder(CreateOrderRequestDto request) => _backend.createOrder(request);

  @override
  Future<List<VendorProfile>> getDiscoveryVendors({required int radiusKm}) =>
      _backend.getDiscoveryVendors(radiusKm: radiusKm);

  @override
  Future<Order> getOrder(String orderId) => _backend.getOrder(orderId);

  @override
  Future<List<Order>> getOrders() => _backend.getOrders();

  @override
  Future<List<Order>> getVendorOrders() => _backend.getVendorOrders();

  @override
  Future<UploadPreparation> preparePaymentProofUpload(
    PreparePaymentProofUploadRequestDto request,
  ) {
    return _backend.preparePaymentProofUpload(
      orderId: request.orderId,
      fileName: request.fileName,
      contentType: request.contentType,
    );
  }

  @override
  Future<List<SubscriptionPlan>> getPlans() => _backend.getPlans();

  @override
  Future<VendorProfile> getVendor(String vendorId) => _backend.getVendor(vendorId);

  @override
  Future<Order> updateVendorOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) {
    return _backend.updateVendorOrderStatus(orderId: orderId, status: status);
  }

  @override
  Future<List<TrustRelationship>> getVendorTrustRequests() =>
      _backend.getVendorTrustRequests();

  @override
  Future<TrustRelationship> requestTrust(String vendorId) => _backend.requestTrust(vendorId);

  @override
  Future<void> reviewTrustRequest({
    required String vendorId,
    required String userId,
    required TrustStatus status,
  }) {
    return _backend.approveTrust(
      vendorId: vendorId,
      userId: userId,
      status: status,
    );
  }

  @override
  Future<Order> uploadPaymentProof(UploadPaymentProofRequestDto request) {
    return _backend.uploadPaymentProof(
      orderId: request.orderId,
      assetPath: request.assetPath,
    );
  }
}

class MockChatRepository implements ChatRepository {
  MockChatRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<List<ChatMessage>> getMessages(String orderId) => _backend.getMessages(orderId);

  @override
  Future<ChatMessage> sendOrderMessage({
    required String orderId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic> metadata = const {},
  }) async {
    final roomId = await _backend.getRoomIdForOrder(orderId);
    return _backend.sendMessage(
      SendMessageRequestDto(
        roomId: roomId,
        type: type,
        content: content,
        metadata: metadata,
      ),
    );
  }
}
