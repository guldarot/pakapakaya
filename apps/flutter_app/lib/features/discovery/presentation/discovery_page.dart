import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/application/auth_controller.dart';
import '../../../features/discovery/application/discovery_controller.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/app_scaffold.dart';

class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final vendorsAsync = ref.watch(discoveryVendorsProvider);
    final radius = ref.watch(discoveryRadiusProvider);

    return AppScaffold(
      title: 'Discovery',
      actions: [
        if (auth.user?.role == UserRole.vendor || auth.user?.role == UserRole.admin)
          IconButton(
            tooltip: 'Vendor center',
            onPressed: () => context.push('/vendor-center'),
            icon: const Icon(Icons.storefront_outlined),
          ),
        if (auth.user?.role == UserRole.admin)
          IconButton(
            tooltip: 'Admin',
            onPressed: () => context.push('/admin'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
          ),
        IconButton(
          tooltip: 'Logout',
          onPressed: auth.isLoading
              ? null
              : () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby cooks for ${auth.user?.name ?? 'you'}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Trust-gated discovery keeps the experience local, private, and safer for both buyers and cooks.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            children: [1, 2, 5].map((option) {
              return ChoiceChip(
                label: Text('$option km'),
                selected: radius == option,
                onSelected: (_) =>
                    ref.read(discoveryRadiusProvider.notifier).state = option,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: vendorsAsync.when(
              data: (vendors) => ListView.separated(
                itemCount: vendors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.push('/vendor/${vendor.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    vendor.storeName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _TrustBadge(status: vendor.trustStatus),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(vendor.bio),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(fuzzDistance(vendor.fuzzedDistanceKm)),
                                const Spacer(),
                                Text(
                                  vendor.customStatus ?? vendor.status.name.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.status});

  final TrustStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TrustStatus.approved => Colors.green,
      TrustStatus.pending => Colors.orange,
      TrustStatus.blocked => Colors.red,
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
