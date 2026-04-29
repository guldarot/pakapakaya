import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';
import '../../../shared/widgets/app_scaffold.dart';

final trustRequestsProvider = FutureProvider<List<TrustRelationship>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getVendorTrustRequests();
});

class VendorDashboardPage extends ConsumerWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(trustRequestsProvider);
    final repository = ref.watch(marketplaceRepositoryProvider);

    return AppScaffold(
      title: 'Vendor Center',
      child: requestsAsync.when(
        data: (requests) => ListView(
          children: [
            const Text(
              'Pending trust requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending requests right now.'),
                ),
              ),
            ...requests.map((request) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text('Buyer ${request.userId} requested access.')),
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
            }),
          ],
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
