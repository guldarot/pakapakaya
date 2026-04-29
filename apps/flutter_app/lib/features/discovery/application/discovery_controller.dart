import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';

final discoveryRadiusProvider = StateProvider<int>((ref) => 1);

final discoveryVendorsProvider = FutureProvider<List<VendorProfile>>((ref) async {
  final radius = ref.watch(discoveryRadiusProvider);
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getDiscoveryVendors(radiusKm: radius);
});

String fuzzDistance(double km) {
  if (km < 0.5) return 'Less than 500m away';
  if (km < 1.0) return 'About 800m away';
  if (km < 2.0) return 'About 1.5km away';
  return 'About ${km.floor()}km away';
}
