import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/chat_repository.dart';
import '../../../shared/repositories/repository_providers.dart';

class ChatController extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatController(this._repository, this.orderId) : super(const AsyncValue.loading()) {
    load();
  }

  final ChatRepository _repository;
  final String orderId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMessages(orderId));
  }

  Future<void> send(String content) async {
    final current = state.value ?? const <ChatMessage>[];
    final sent = await _repository.sendOrderMessage(
      orderId: orderId,
      content: content,
    );
    state = AsyncValue.data([...current, sent]);
  }
}

final chatControllerProvider = StateNotifierProvider.family
    .autoDispose<ChatController, AsyncValue<List<ChatMessage>>, String>(
  (ref, orderId) => ChatController(ref.watch(chatRepositoryProvider), orderId),
);
