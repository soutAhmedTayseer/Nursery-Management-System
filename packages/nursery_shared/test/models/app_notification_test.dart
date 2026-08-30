import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('AppNotification round-trips JSON', () {
    final json = {
      'id': 'n1',
      'recipient_id': 'g1',
      'recipient_type': 'guardian',
      'type': 'checkin_confirmed',
      'payload': {'kid_id': 'k1', 'session_id': 'se2'},
      'sent_at': '2026-02-01T08:00:05.000Z',
      'read_at': null,
    };

    final notification = AppNotification.fromJson(json);

    expect(notification.type, 'checkin_confirmed');
    expect(notification.payload['kid_id'], 'k1');
    expect(notification.toJson(), json);
  });
}
