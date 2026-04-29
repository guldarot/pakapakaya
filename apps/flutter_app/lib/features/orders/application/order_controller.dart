import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/repository_providers.dart';

class OrderDraft {
  const OrderDraft({
    this.quantity = 1,
    this.isByob = false,
    this.mode = DeliveryMode.pickup,
  });

  final int quantity;
  final bool isByob;
  final DeliveryMode mode;

  OrderDraft copyWith({
    int? quantity,
    bool? isByob,
    DeliveryMode? mode,
  }) {
    return OrderDraft(
      quantity: quantity ?? this.quantity,
      isByob: isByob ?? this.isByob,
      mode: mode ?? this.mode,
    );
  }
}

class OrderDraftController extends StateNotifier<OrderDraft> {
  OrderDraftController() : super(const OrderDraft());

  void setQuantity(int quantity) => state = state.copyWith(quantity: quantity);
  void toggleByob(bool value) => state = state.copyWith(isByob: value);
}

final orderDraftProvider =
    StateNotifierProvider.autoDispose<OrderDraftController, OrderDraft>(
  (ref) => OrderDraftController(),
);

final orderListProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getOrders();
});

final orderProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getOrder(orderId);
});
