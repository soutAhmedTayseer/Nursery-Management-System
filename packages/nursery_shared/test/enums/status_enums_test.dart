import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('KidStatus round-trips wire values', () {
    expect(KidStatus.fromValue('pending_approval'), KidStatus.pendingApproval);
    expect(KidStatus.active.value, 'active');
    expect(() => KidStatus.fromValue('bogus'), throwsArgumentError);
  });

  test('SessionStatus round-trips wire values', () {
    expect(SessionStatus.fromValue('pending_confirmation'), SessionStatus.pendingConfirmation);
    expect(SessionStatus.completed.value, 'completed');
  });

  test('SubscriptionStatus round-trips wire values', () {
    expect(SubscriptionStatus.fromValue('depleted'), SubscriptionStatus.depleted);
    expect(SubscriptionStatus.active.value, 'active');
  });
}
