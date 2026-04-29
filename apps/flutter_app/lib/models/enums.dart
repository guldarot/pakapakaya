enum UserRole { user, vendor, admin }

enum UserStatus { active, suspended }

enum VendorStatus { open, paused, closed }

enum SubscriptionTier { free, standard, pro }

enum DeliveryMode { pickup, delivery }

enum TrustStatus { pending, approved, blocked }

enum BatchStatus { draft, open, closed, completed }

enum OrderStatus {
  pendingPayment,
  verification,
  confirmed,
  ready,
  completed,
  cancelled,
  noShow,
  barakat,
}

enum PaymentStatus { pending, uploaded, confirmed, rejected }

enum MessageType { text, image, audio, offer, system }

enum MessageDeliveryState { sending, sent, delivered, failed }

enum ModerationStatus { open, reviewing, resolved, dismissed }

enum PaymentMethodType { easypaisa, bankTransfer, jazzCash }
