import 'enums.dart';

class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.status,
    required this.trustScore,
    required this.codStrikeCount,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.locationPoint,
  });

  final String id;
  final String phone;
  final String name;
  final String? imageUrl;
  final UserRole role;
  final UserStatus status;
  final int trustScore;
  final int codStrikeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GeoPoint? locationPoint;
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.label,
    required this.accountName,
    required this.maskedAccount,
    required this.instructions,
    required this.isActive,
  });

  final String id;
  final String vendorId;
  final PaymentMethodType type;
  final String label;
  final String accountName;
  final String maskedAccount;
  final String instructions;
  final bool isActive;
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.code,
    required this.maxInventoryItems,
    required this.maxMonthlyOrders,
    required this.features,
  });

  final SubscriptionTier code;
  final int maxInventoryItems;
  final int maxMonthlyOrders;
  final List<String> features;
}

class VendorProfile {
  const VendorProfile({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.bio,
    required this.status,
    required this.subscriptionTier,
    required this.packagingCost,
    required this.deliveryModes,
    required this.monthlyOrderCount,
    required this.billingCycleStart,
    required this.verifiedBadge,
    required this.paymentMethods,
    required this.user,
    required this.trustStatus,
    required this.fuzzedDistanceKm,
    required this.inventoryItems,
    required this.batches,
    this.customStatus,
  });

  final String id;
  final String userId;
  final String storeName;
  final String bio;
  final VendorStatus status;
  final SubscriptionTier subscriptionTier;
  final double packagingCost;
  final List<DeliveryMode> deliveryModes;
  final int monthlyOrderCount;
  final DateTime billingCycleStart;
  final bool verifiedBadge;
  final List<PaymentMethod> paymentMethods;
  final AppUser user;
  final TrustStatus trustStatus;
  final double fuzzedDistanceKm;
  final List<InventoryItem> inventoryItems;
  final List<Batch> batches;
  final String? customStatus;
}

class TrustRelationship {
  const TrustRelationship({
    required this.vendorId,
    required this.userId,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
    this.reviewReason,
  });

  final String vendorId;
  final String userId;
  final TrustStatus status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewReason;
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.isActive,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String? imageUrl;
  final double basePrice;
  final bool isActive;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Batch {
  const Batch({
    required this.id,
    required this.itemId,
    required this.availableFrom,
    required this.availableUntil,
    required this.cutoffTime,
    required this.maxQuantity,
    required this.remainingQuantity,
    required this.status,
    required this.acceptOrdersDuringPrep,
    required this.createdAt,
    required this.updatedAt,
    required this.item,
  });

  final String id;
  final String itemId;
  final DateTime availableFrom;
  final DateTime availableUntil;
  final DateTime cutoffTime;
  final int maxQuantity;
  final int remainingQuantity;
  final BatchStatus status;
  final bool acceptOrdersDuringPrep;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InventoryItem item;
}

class DeliveryAddressSnapshot {
  const DeliveryAddressSnapshot({
    required this.label,
    required this.addressLine,
    this.locationPoint,
  });

  final String label;
  final String addressLine;
  final GeoPoint? locationPoint;
}

class Order {
  const Order({
    required this.id,
    required this.batchId,
    required this.buyerId,
    required this.vendorId,
    required this.status,
    required this.logisticsMode,
    required this.isByob,
    required this.quantity,
    required this.unitPriceSnapshot,
    required this.packagingFeeSnapshot,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.batch,
    this.paymentScreenshotUrl,
    this.deliveryAddressSnapshot,
  });

  final String id;
  final String batchId;
  final String buyerId;
  final String vendorId;
  final OrderStatus status;
  final DeliveryMode logisticsMode;
  final bool isByob;
  final int quantity;
  final double unitPriceSnapshot;
  final double packagingFeeSnapshot;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final String? paymentScreenshotUrl;
  final DeliveryAddressSnapshot? deliveryAddressSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Batch batch;
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.orderId,
    required this.vendorId,
    required this.buyerId,
    required this.isBlocked,
    required this.lastMessageAt,
  });

  final String id;
  final String orderId;
  final String vendorId;
  final String buyerId;
  final bool isBlocked;
  final DateTime lastMessageAt;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.deliveryState,
    required this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String roomId;
  final String senderId;
  final MessageType type;
  final String content;
  final Map<String, dynamic> metadata;
  final MessageDeliveryState deliveryState;
  final DateTime createdAt;
}

class ModerationReport {
  const ModerationReport({
    required this.id,
    required this.reporterId,
    required this.targetUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.messageId,
    this.roomId,
  });

  final String id;
  final String reporterId;
  final String targetUserId;
  final String? messageId;
  final String? roomId;
  final String reason;
  final ModerationStatus status;
  final DateTime createdAt;
}

class BarakatMeal {
  const BarakatMeal({
    required this.id,
    required this.vendorId,
    required this.batchId,
    required this.title,
    required this.expiresAt,
  });

  final String id;
  final String vendorId;
  final String batchId;
  final String title;
  final DateTime expiresAt;
}

class GiftMeal {
  const GiftMeal({
    required this.id,
    required this.orderId,
    required this.senderUserId,
    required this.recipientLabel,
    required this.isAnonymous,
  });

  final String id;
  final String orderId;
  final String senderUserId;
  final String recipientLabel;
  final bool isAnonymous;
}

class CodStrike {
  const CodStrike({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String orderId;
  final String reason;
  final DateTime createdAt;
}
