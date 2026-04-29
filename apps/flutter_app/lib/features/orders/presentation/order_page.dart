import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../application/order_controller.dart';

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final repository = ref.watch(marketplaceRepositoryProvider);

    return AppScaffold(
      title: 'Order Detail',
      child: orderAsync.when(
        data: (order) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.batch.item.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${order.status.name}'),
                    Text('Payment: ${order.paymentStatus.name}'),
                    Text('Quantity: ${order.quantity}'),
                    Text('Total: PKR ${order.totalAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: order.paymentStatus == PaymentStatus.pending
                  ? () async {
                      await repository.uploadPaymentProof(
                        UploadPaymentProofRequestDto(
                          orderId: order.id,
                          assetPath: 'mock://payment-proof.png',
                        ),
                      );
                      ref.invalidate(orderProvider(order.id));
                    }
                  : null,
              child: const Text('Upload mock payment proof'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/chat/${order.id}'),
              child: const Text('Open secure chat'),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
