import '../../models/models.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String orderId);

  Future<ChatMessage> sendOrderMessage({
    required String orderId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic> metadata = const {},
  });
}
