import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Session round-trips JSON for a pending guardian-requested check-in', () {
    final json = {
      'id': 'se1',
      'kid_id': 'k1',
      'requested_by': 'guardian',
      'requested_by_id': 'g1',
      'status': 'pending_confirmation',
      'checked_in_at': null,
      'confirmed_by': null,
      'checked_out_at': null,
      'checked_out_confirmed_by': null,
      'hours_deducted': null,
      'subscription_id': null,
      'allowed_hours': 3.0,
    };

    final session = Session.fromJson(json);

    expect(session.status, SessionStatus.pendingConfirmation);
    expect(session.checkedInAt, isNull);
    expect(session.toJson(), json);
  });

  test('Session round-trips JSON for a completed session', () {
    final json = {
      'id': 'se2',
      'kid_id': 'k1',
      'requested_by': 'admin',
      'requested_by_id': 'a1',
      'status': 'completed',
      'checked_in_at': '2026-02-01T08:00:00.000Z',
      'confirmed_by': 'a1',
      'checked_out_at': '2026-02-01T12:00:00.000Z',
      'checked_out_confirmed_by': 'a1',
      'hours_deducted': 4.0,
      'subscription_id': 's1',
      'allowed_hours': 3.0,
    };

    final session = Session.fromJson(json);

    expect(session.hoursDeducted, 4.0);
    expect(session.toJson(), json);
  });
}
