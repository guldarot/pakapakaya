import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
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
    final currentUser = ref.watch(authControllerProvider).user;

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
            if (currentUser?.role == UserRole.user)
              FilledButton(
                onPressed: order.paymentStatus == PaymentStatus.pending
                    ? () async {
                        final upload = await repository.preparePaymentProofUpload(
                          PreparePaymentProofUploadRequestDto(
                            orderId: order.id,
                            fileName: 'payment-proof.txt',
                            contentType: 'text/plain',
                          ),
                        );
                        await repository.uploadPaymentProof(
                          UploadPaymentProofRequestDto(
                            orderId: order.id,
                            assetPath: upload.publicUrl,
                          ),
                        );
                        ref.invalidate(orderProvider(order.id));
                      }
                    : null,
                child: const Text('Upload mock payment proof'),
              ),
            if (currentUser?.role == UserRole.vendor) ...[
              if (_nextVendorStatus(order.status) case final nextStatus?)
                FilledButton(
                  onPressed: () async {
                    await repository.updateVendorOrderStatus(
                      orderId: order.id,
                      status: nextStatus,
                    );
                    ref.invalidate(orderProvider(order.id));
                    ref.invalidate(orderListProvider);
                  },
                  child: Text(_actionLabel(nextStatus)),
                )
              else
                const Text('No vendor action needed for this order right now.'),
            ],
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

OrderStatus? _nextVendorStatus(OrderStatus status) {
  return switch (status) {
    OrderStatus.verification => OrderStatus.confirmed,
    OrderStatus.confirmed => OrderStatus.ready,
    OrderStatus.ready => OrderStatus.completed,
    _ => null,
  };
}

String _actionLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.confirmed => 'Confirm payment',
    OrderStatus.ready => 'Mark ready',
    OrderStatus.completed => 'Complete order',
    _ => status.name,
  };
}
