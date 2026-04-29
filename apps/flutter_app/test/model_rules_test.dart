import 'package:flutter_test/flutter_test.dart';
import 'package:pakapakaya_flutter/models/models.dart';

void main() {
  test('approved trust is distinct from pending trust', () {
    expect(TrustStatus.approved == TrustStatus.pending, isFalse);
  });

  test('order lifecycle enum keeps verification before confirmed', () {
    const statuses = OrderStatus.values;
    expect(
      statuses.indexOf(OrderStatus.verification),
      lessThan(statuses.indexOf(OrderStatus.confirmed)),
    );
  });

  test('subscription tiers include free, standard, and pro', () {
    expect(
      SubscriptionTier.values,
      containsAll([SubscriptionTier.free, SubscriptionTier.standard, SubscriptionTier.pro]),
    );
  });
}
