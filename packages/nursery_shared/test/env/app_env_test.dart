import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('defaults to the live API and dev env when no --dart-define is passed', () {
    expect(AppEnv.apiBaseUrl, 'https://nursery-management-api.runasp.net/api');
    expect(AppEnv.name, 'dev');
    expect(AppEnv.isProd, isFalse);
  });
}
