import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/l10n/api_error_messages.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  group('apiErrorKey', () {
    test('lowercases and prefixes the backend error code', () {
      const exception = ApiException(
        code: 'KID_NOT_FOUND',
        message: 'Kid not found',
        statusCode: 404,
      );
      expect(apiErrorKey(exception), 'error_kid_not_found');
    });

    test('maps the network failure code', () {
      const exception = ApiException(
        code: 'NETWORK_ERROR',
        message: 'Connection failed',
        statusCode: null,
      );
      expect(apiErrorKey(exception), 'error_network_error');
    });

    test('falls back to the generic key for an empty code', () {
      const exception = ApiException(
        code: '',
        message: 'weird',
        statusCode: 500,
      );
      expect(apiErrorKey(exception), 'error_generic');
    });
  });
}
