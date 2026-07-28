import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/bootstrap.dart';

void main() {
  test('MyApp widget compiles and is constructible', () {
    // Verify the app widget class exists and can be instantiated
    const app = MyApp();
    expect(app, isNotNull);
    expect(app.key, isNull);
  });
}
