import '../../models/models.dart';

abstract class MarketplaceRepository {
  Future<List<SubscriptionPlan>> getPlans();

  Future<List<VendorProfile>> getDiscoveryVendors({required int radiusKm});

  Future<VendorProfile> getVendor(String vendorId);

  Future<TrustRelationship> requestTrust(String vendorId);

  Future<List<TrustRelationship>> getVendorTrustRequests();

  Future<void> reviewTrustRequest({
    required String vendorId,
    required String userId,
    required TrustStatus status,
  });

  Future<Order> createOrder(CreateOrderRequestDto request);

  Future<List<Order>> getOrders();

  Future<List<Order>> getVendorOrders();

  Future<Order> getOrder(String orderId);

  Future<Order> updateVendorOrderStatus({
    required String orderId,
    required OrderStatus status,
  });

  Future<UploadPreparation> preparePaymentProofUpload(
    PreparePaymentProofUploadRequestDto request,
  );

  Future<Order> uploadPaymentProof(UploadPaymentProofRequestDto request);
}
