import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';
import '../../../shared/widgets/app_scaffold.dart';

final trustRequestsProvider = FutureProvider<List<TrustRelationship>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getVendorTrustRequests();
});

final vendorOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getVendorOrders();
});

class VendorDashboardPage extends ConsumerWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(trustRequestsProvider);
    final ordersAsync = ref.watch(vendorOrdersProvider);
    final repository = ref.watch(marketplaceRepositoryProvider);

    return AppScaffold(
      title: 'Vendor Center',
      child: ListView(
        children: [
          const Text(
            'Pending trust requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          requestsAsync.when(
            data: (requests) => requests.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No pending requests right now.'),
                    ),
                  )
                : Column(
                    children: requests.map((request) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('Buyer ${request.userId} requested access.'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await repository.reviewTrustRequest(
                                    vendorId: request.vendorId,
                                    userId: request.userId,
                                    status: TrustStatus.blocked,
                                  );
                                  ref.invalidate(trustRequestsProvider);
                                },
                                child: const Text('Block'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  await repository.reviewTrustRequest(
                                    vendorId: request.vendorId,
                                    userId: request.userId,
                                    status: TrustStatus.approved,
                                  );
                                  ref.invalidate(trustRequestsProvider);
                                },
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error.toString()),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Order queue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ordersAsync.when(
            data: (orders) => orders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No buyer orders yet.'),
                    ),
                  )
                : Column(
                    children: orders.map((order) {
                      final nextStatus = _nextVendorStatus(order.status);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.batch.item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _OrderStatusBadge(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Buyer: ${order.buyerId}'),
                              Text('Qty ${order.quantity} • Rs ${order.totalAmount.toStringAsFixed(0)}'),
                              Text('Payment: ${order.paymentStatus.name.toUpperCase()}'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.push('/orders/${order.id}'),
                                    child: const Text('View'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => context.push('/chat/${order.id}'),
                                    child: const Text('Chat'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (nextStatus != null)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: () async {
                                      await repository.updateVendorOrderStatus(
                                        orderId: order.id,
                                        status: nextStatus,
                                      );
                                      ref.invalidate(vendorOrdersProvider);
                                    },
                                    child: Text(_actionLabel(nextStatus)),
                                  ),
                                )
                              else
                                const Text(
                                  'No vendor action needed.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error.toString()),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
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

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.verification => Colors.orange,
      OrderStatus.confirmed => Colors.blue,
      OrderStatus.ready => Colors.deepPurple,
      OrderStatus.completed => Colors.green,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
