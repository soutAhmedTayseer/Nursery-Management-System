import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Guardian round-trips JSON', () {
    final json = {
      'id': 'g1',
      'full_name': 'Sara Ahmed',
      'email': 'sara@example.com',
      'phone': '+201000000000',
      'auth_provider': 'google',
      'created_at': '2026-01-15T10:00:00.000Z',
    };

    final guardian = Guardian.fromJson(json);

    expect(guardian.id, 'g1');
    expect(guardian.fullName, 'Sara Ahmed');
    expect(guardian.authProvider, 'google');
    expect(guardian.createdAt, DateTime.parse('2026-01-15T10:00:00.000Z'));
    expect(guardian.toJson(), json);
  });
}
