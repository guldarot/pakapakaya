import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/application/auth_controller.dart';
import '../../orders/application/order_controller.dart';
import '../application/chat_controller.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatControllerProvider(widget.orderId));
    final currentUserId = ref.watch(authControllerProvider).user?.id;

    return AppScaffold(
      title: 'Secure Chat',
      child: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.senderId == currentUserId
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message.content),
                      ),
                    ),
                  );
                },
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  if (_textController.text.trim().isEmpty) {
                    return;
                  }
                  await ref.read(orderProvider(widget.orderId).future);
                  await ref
                      .read(chatControllerProvider(widget.orderId).notifier)
                      .send(_textController.text);
                  _textController.clear();
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
