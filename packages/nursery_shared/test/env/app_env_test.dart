import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('defaults to localhost API and dev env when no --dart-define is passed', () {
    expect(AppEnv.apiBaseUrl, 'http://localhost:8080/api/v1');
    expect(AppEnv.name, 'dev');
    expect(AppEnv.isProd, isFalse);
  });
}
