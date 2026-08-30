import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Admin round-trips JSON', () {
    final json = {
      'id': 'a1',
      'full_name': 'Nursery Owner',
      'email': 'owner@example.com',
      'created_at': '2026-01-01T09:00:00.000Z',
    };

    final admin = Admin.fromJson(json);

    expect(admin.id, 'a1');
    expect(admin.fullName, 'Nursery Owner');
    expect(admin.toJson(), json);
  });
}
