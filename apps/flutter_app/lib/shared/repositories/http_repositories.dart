import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/session_store.dart';
import '../../models/api_dtos.dart';
import '../../models/domain_models.dart';
import '../../models/enums.dart';
import '../../models/json_mappers.dart';
import 'auth_repository.dart';
import 'chat_repository.dart';
import 'marketplace_repository.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._client, this._sessionStore);

  final ApiClient _client;
  final SessionStore _sessionStore;
  AppUser? _currentUser;

  @override
  AppUser? get currentUserOrNull => _currentUser;

  @override
  Future<AppUser> loginDemo() async {
    final response = await _client.post(
      ApiEndpoints.authLogin,
      data: const OtpLoginRequestDto(
        phone: '+923001234567',
        otpCode: '123456',
      ).toJson(),
    );
    final bootstrap = JsonMappers.bootstrapResponse(
      (response.data as Map).cast<String, dynamic>(),
    );
    _currentUser = bootstrap.currentUser;
    await _sessionStore.setSession(
      token: bootstrap.token,
      user: bootstrap.currentUser,
    );
    return bootstrap.currentUser;
  }
}

class HttpMarketplaceRepository implements MarketplaceRepository {
  HttpMarketplaceRepository(this._client);

  final ApiClient _client;

  @override
  Future<Order> createOrder(CreateOrderRequestDto request) async {
    final response = await _client.post(ApiEndpoints.orders, data: request.toJson());
    return JsonMappers.order((response.data as Map).cast<String, dynamic>());
  }

  @override
  Future<List<VendorProfile>> getDiscoveryVendors({required int radiusKm}) async {
    final response = await _client.get(
      ApiEndpoints.discovery,
      queryParameters: {'radiusKm': radiusKm},
    );
    return ((response.data as List?) ?? const [])
        .map((item) => JsonMappers.vendorProfile((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<Order> getOrder(String orderId) async {
    final response = await _client.get('${ApiEndpoints.orders}/$orderId');
    return JsonMappers.order((response.data as Map).cast<String, dynamic>());
  }

  @override
  Future<List<Order>> getOrders() async {
    final response = await _client.get(ApiEndpoints.orders);
    return ((response.data as List?) ?? const [])
        .map((item) => JsonMappers.order((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _client.get('${ApiEndpoints.admin}/plans');
    return ((response.data as List?) ?? const [])
        .map((item) => JsonMappers.subscriptionPlan((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<VendorProfile> getVendor(String vendorId) async {
    final response = await _client.get('${ApiEndpoints.vendor}/$vendorId');
    return JsonMappers.vendorProfile((response.data as Map).cast<String, dynamic>());
  }

  @override
  Future<List<TrustRelationship>> getVendorTrustRequests() async {
    final response = await _client.get('${ApiEndpoints.trust}/requests');
    return ((response.data as List?) ?? const [])
        .map((item) => JsonMappers.trustRelationship((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<TrustRelationship> requestTrust(String vendorId) async {
    final response = await _client.post(
      '${ApiEndpoints.trust}/requests',
      data: TrustRequestDto(vendorId: vendorId).toJson(),
    );
    return JsonMappers.trustRelationship((response.data as Map).cast<String, dynamic>());
  }

  @override
  Future<void> reviewTrustRequest({
    required String vendorId,
    required String userId,
    required TrustStatus status,
  }) async {
    await _client.patch(
      '${ApiEndpoints.trust}/requests/$vendorId/$userId',
      data: {'status': status.name},
    );
  }

  @override
  Future<Order> uploadPaymentProof(UploadPaymentProofRequestDto request) async {
    final response = await _client.post(
      '${ApiEndpoints.orders}/${request.orderId}/payment-proof',
      data: request.toJson(),
    );

    final partial = (response.data as Map).cast<String, dynamic>();
    if (!partial.containsKey('batch')) {
      return getOrder(request.orderId);
    }
    return JsonMappers.order(partial);
  }
}

class HttpChatRepository implements ChatRepository {
  HttpChatRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ChatMessage>> getMessages(String orderId) async {
    final response = await _client.get('${ApiEndpoints.chat}/orders/$orderId/messages');
    return ((response.data as List?) ?? const [])
        .map((item) => JsonMappers.chatMessage((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<ChatMessage> sendOrderMessage({
    required String orderId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic> metadata = const {},
  }) async {
    final response = await _client.post(
      '${ApiEndpoints.chat}/orders/$orderId/messages',
      data: {
        'type': type.name,
        'content': content,
        'metadata': metadata,
      },
    );
    return JsonMappers.chatMessage((response.data as Map).cast<String, dynamic>());
  }
}
