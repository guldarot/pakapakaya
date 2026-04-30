import 'api_dtos.dart';
import 'domain_models.dart';
import 'enums.dart';

class JsonMappers {
  static DateTime _readDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static double _readDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static T _readEnum<T>(
    dynamic raw,
    List<T> values,
    String Function(T value) nameOf,
    T fallback,
  ) {
    if (raw is! String) {
      return fallback;
    }

    for (final value in values) {
      if (nameOf(value).toLowerCase() == raw.toLowerCase()) {
        return value;
      }
    }

    return fallback;
  }

  static AppUser appUser(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: json['imageUrl'] as String?,
      role: _readEnum(json['role'], UserRole.values, (it) => it.name, UserRole.user),
      status: _readEnum(
        json['status'],
        UserStatus.values,
        (it) => it.name,
        UserStatus.active,
      ),
      trustScore: _readInt(json['trustScore'], fallback: 100),
      codStrikeCount: _readInt(json['codStrikeCount']),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      locationPoint: (json['latitude'] != null && json['longitude'] != null)
          ? GeoPoint(
              latitude: _readDouble(json['latitude']),
              longitude: _readDouble(json['longitude']),
            )
          : null,
    );
  }

  static PaymentMethod paymentMethod(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      type: _readEnum(
        json['type'],
        PaymentMethodType.values,
        (it) => it.name,
        PaymentMethodType.easypaisa,
      ),
      label: json['label'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      maskedAccount: json['maskedAccount'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  static SubscriptionPlan subscriptionPlan(Map<String, dynamic> json) {
    return SubscriptionPlan(
      code: _readEnum(
        json['code'],
        SubscriptionTier.values,
        (it) => it.name,
        SubscriptionTier.free,
      ),
      maxInventoryItems: _readInt(json['maxInventoryItems']),
      maxMonthlyOrders: _readInt(json['maxMonthlyOrders']),
      features: ((json['features'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  static InventoryItem inventoryItem(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      basePrice: _readDouble(json['basePrice']),
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'] as String? ?? 'General',
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  static Batch batch(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      availableFrom: _readDate(json['availableFrom']),
      availableUntil: _readDate(json['availableUntil']),
      cutoffTime: _readDate(json['cutoffTime']),
      maxQuantity: _readInt(json['maxQuantity']),
      remainingQuantity: _readInt(json['remainingQuantity']),
      status: _readEnum(json['status'], BatchStatus.values, (it) => it.name, BatchStatus.open),
      acceptOrdersDuringPrep: json['acceptOrdersDuringPrep'] as bool? ?? false,
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      item: inventoryItem((json['item'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }

  static VendorProfile vendorProfile(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      status: _readEnum(
        json['status'],
        VendorStatus.values,
        (it) => it.name,
        VendorStatus.open,
      ),
      subscriptionTier: _readEnum(
        json['subscriptionTier'],
        SubscriptionTier.values,
        (it) => it.name,
        SubscriptionTier.free,
      ),
      packagingCost: _readDouble(json['packagingCost']),
      deliveryModes: ((json['deliveryModes'] as List?) ?? const [])
          .map(
            (item) => _readEnum(
              item,
              DeliveryMode.values,
              (it) => it.name,
              DeliveryMode.pickup,
            ),
          )
          .toList(),
      monthlyOrderCount: _readInt(json['monthlyOrderCount']),
      billingCycleStart: _readDate(json['billingCycleStart']),
      verifiedBadge: json['verifiedBadge'] as bool? ?? false,
      paymentMethods: ((json['paymentMethods'] as List?) ?? const [])
          .map((item) => paymentMethod((item as Map).cast<String, dynamic>()))
          .toList(),
      user: appUser((json['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
      trustStatus: _readEnum(
        json['trustStatus'],
        TrustStatus.values,
        (it) => it.name,
        TrustStatus.pending,
      ),
      fuzzedDistanceKm: _readDouble(json['fuzzedDistanceKm']),
      inventoryItems: ((json['inventoryItems'] as List?) ?? const [])
          .map((item) => inventoryItem((item as Map).cast<String, dynamic>()))
          .toList(),
      batches: ((json['batches'] as List?) ?? const [])
          .map((item) => batch((item as Map).cast<String, dynamic>()))
          .toList(),
      customStatus: json['customStatus'] as String?,
    );
  }

  static TrustRelationship trustRelationship(Map<String, dynamic> json) {
    return TrustRelationship(
      vendorId: json['vendorId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: _readEnum(
        json['status'],
        TrustStatus.values,
        (it) => it.name,
        TrustStatus.pending,
      ),
      requestedAt: _readDate(json['requestedAt']),
      reviewedAt: json['reviewedAt'] == null ? null : _readDate(json['reviewedAt']),
      reviewReason: json['reviewReason'] as String?,
    );
  }

  static DeliveryAddressSnapshot? deliveryAddressSnapshot(dynamic json) {
    if (json is! Map) {
      return null;
    }

    return DeliveryAddressSnapshot(
      label: json['label'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      locationPoint: (json['latitude'] != null && json['longitude'] != null)
          ? GeoPoint(
              latitude: _readDouble(json['latitude']),
              longitude: _readDouble(json['longitude']),
            )
          : null,
    );
  }

  static Order order(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      status: _readEnum(
        json['status'],
        OrderStatus.values,
        (it) => it.name,
        OrderStatus.pendingPayment,
      ),
      logisticsMode: _readEnum(
        json['logisticsMode'],
        DeliveryMode.values,
        (it) => it.name,
        DeliveryMode.pickup,
      ),
      isByob: json['isByob'] as bool? ?? false,
      quantity: _readInt(json['quantity'], fallback: 1),
      unitPriceSnapshot: _readDouble(json['unitPriceSnapshot']),
      packagingFeeSnapshot: _readDouble(json['packagingFeeSnapshot']),
      totalAmount: _readDouble(json['totalAmount']),
      paymentStatus: _readEnum(
        json['paymentStatus'],
        PaymentStatus.values,
        (it) => it.name,
        PaymentStatus.pending,
      ),
      paymentScreenshotUrl: json['paymentScreenshotUrl'] as String?,
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
      batch: batch((json['batch'] as Map?)?.cast<String, dynamic>() ?? const {}),
      deliveryAddressSnapshot: deliveryAddressSnapshot(json['deliveryAddressSnapshot']),
    );
  }

  static ChatMessage chatMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      type: _readEnum(
        json['type'],
        MessageType.values,
        (it) => it.name,
        MessageType.text,
      ),
      content: json['content'] as String? ?? '',
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      deliveryState: _readEnum(
        json['deliveryState'],
        MessageDeliveryState.values,
        (it) => it.name,
        MessageDeliveryState.sent,
      ),
      createdAt: _readDate(json['createdAt']),
    );
  }

  static BootstrapResponseDto bootstrapResponse(Map<String, dynamic> json) {
    return BootstrapResponseDto(
      token: json['token'] as String? ?? '',
      currentUser: appUser((json['currentUser'] as Map?)?.cast<String, dynamic>() ?? const {}),
      availablePlans: ((json['availablePlans'] as List?) ?? const [])
          .map((item) => subscriptionPlan((item as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  static UploadPreparation uploadPreparation(Map<String, dynamic> json) {
    return UploadPreparation(
      assetPath: json['assetPath'] as String? ?? '',
      uploadUrl: json['uploadUrl'] as String? ?? '',
      publicUrl: json['publicUrl'] as String? ?? '',
      method: json['method'] as String? ?? 'PUT',
      headers: ((json['headers'] as Map?) ?? const {})
          .map((key, value) => MapEntry(key.toString(), value.toString())),
    );
  }
}
