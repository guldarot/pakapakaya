import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../discovery/application/discovery_controller.dart';
import '../../orders/application/order_controller.dart';

final vendorProvider = FutureProvider.family<VendorProfile, String>((ref, vendorId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getVendor(vendorId);
});

class VendorPage extends ConsumerWidget {
  const VendorPage({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorProvider(vendorId));
    final draft = ref.watch(orderDraftProvider);
    final repository = ref.watch(marketplaceRepositoryProvider);

    return AppScaffold(
      title: 'Vendor Shop',
      child: vendorAsync.when(
        data: (vendor) => ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.storeName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(vendor.bio),
                    const SizedBox(height: 12),
                    Text('Trust status: ${vendor.trustStatus.name.toUpperCase()}'),
                    const SizedBox(height: 12),
                    if (vendor.trustStatus != TrustStatus.approved)
                      FilledButton.tonal(
                        onPressed: () async {
                          await repository.requestTrust(vendor.id);
                          ref.invalidate(vendorProvider(vendor.id));
                          ref.invalidate(discoveryVendorsProvider);
                        },
                        child: const Text('Request trust approval'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Open batches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...vendor.batches.map((batch) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text('Available: ${batch.availableFrom} - ${batch.availableUntil}'),
                      Text('Remaining: ${batch.remainingQuantity}/${batch.maxQuantity}'),
                      Text('Price per plate: PKR ${batch.item.basePrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: draft.quantity > 1
                                ? () => ref
                                    .read(orderDraftProvider.notifier)
                                    .setQuantity(draft.quantity - 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${draft.quantity}'),
                          IconButton(
                            onPressed: draft.quantity < batch.remainingQuantity
                                ? () => ref
                                    .read(orderDraftProvider.notifier)
                                    .setQuantity(draft.quantity + 1)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          const Spacer(),
                          Switch(
                            value: draft.isByob,
                            onChanged: (value) =>
                                ref.read(orderDraftProvider.notifier).toggleByob(value),
                          ),
                          const Text('BYOB'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: vendor.trustStatus == TrustStatus.approved
                            ? () async {
                                final order = await repository.createOrder(
                                  CreateOrderRequestDto(
                                    batchId: batch.id,
                                    quantity: draft.quantity,
                                    logisticsMode: draft.mode,
                                    isByob: draft.isByob,
                                  ),
                                );
                                if (context.mounted) {
                                  ref.invalidate(orderListProvider);
                                  context.push('/orders/${order.id}');
                                }
                              }
                            : null,
                        child: const Text('Reserve meal'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
