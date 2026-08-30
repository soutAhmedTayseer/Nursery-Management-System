import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Subscription round-trips JSON, including negative hours_remaining (overage debt)', () {
    final json = {
      'id': 's1',
      'kid_id': 'k1',
      'plan_id': 'p1',
      'hours_remaining': -1.5,
      'hours_total': 40.0,
      'purchased_at': '2026-02-01T09:00:00.000Z',
      'recorded_by': 'a1',
      'payment_method': 'cash',
      'notes': 'Paid in person',
      'status': 'depleted',
    };

    final subscription = Subscription.fromJson(json);

    expect(subscription.hoursRemaining, -1.5);
    expect(subscription.status, SubscriptionStatus.depleted);
    expect(subscription.toJson(), json);
  });
}
