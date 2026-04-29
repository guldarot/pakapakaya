import 'domain_models.dart';
import 'enums.dart';

class OtpLoginRequestDto {
  const OtpLoginRequestDto({
    required this.phone,
    required this.otpCode,
  });

  final String phone;
  final String otpCode;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otpCode': otpCode,
      };
}

class TrustRequestDto {
  const TrustRequestDto({
    required this.vendorId,
  });

  final String vendorId;

  Map<String, dynamic> toJson() => {'vendorId': vendorId};
}

class CreateOrderRequestDto {
  const CreateOrderRequestDto({
    required this.batchId,
    required this.quantity,
    required this.logisticsMode,
    required this.isByob,
  });

  final String batchId;
  final int quantity;
  final DeliveryMode logisticsMode;
  final bool isByob;

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'quantity': quantity,
        'logisticsMode': logisticsMode.name,
        'isByob': isByob,
      };
}

class SendMessageRequestDto {
  const SendMessageRequestDto({
    required this.roomId,
    required this.type,
    required this.content,
    this.metadata = const {},
  });

  final String roomId;
  final MessageType type;
  final String content;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'type': type.name,
        'content': content,
        'metadata': metadata,
      };
}

class UploadPaymentProofRequestDto {
  const UploadPaymentProofRequestDto({
    required this.orderId,
    required this.assetPath,
  });

  final String orderId;
  final String assetPath;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'assetPath': assetPath,
      };
}

class BootstrapResponseDto {
  const BootstrapResponseDto({
    required this.token,
    required this.currentUser,
    required this.availablePlans,
  });

  final String token;
  final AppUser currentUser;
  final List<SubscriptionPlan> availablePlans;
}
