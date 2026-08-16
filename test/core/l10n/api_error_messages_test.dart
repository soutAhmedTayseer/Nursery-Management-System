import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/l10n/api_error_messages.dart';
import 'package:nursery_shared/nursery_shared.dart';

/// Every error code in `docs/specs/2026-07-28-backend-api-contract.md` §4,
/// plus the client-only `NETWORK_ERROR`. Adding a code to the contract without
/// adding its translations is what this list exists to catch.
const _contractErrorCodes = <String>[
  'VALIDATION_ERROR',
  'INVALID_CREDENTIALS',
  'TOKEN_EXPIRED',
  'INVALID_REFRESH_TOKEN',
  'UNAUTHORIZED',
  'FORBIDDEN',
  'KID_NOT_FOUND',
  'PLAN_NOT_FOUND',
  'SESSION_NOT_FOUND',
  'SUBSCRIPTION_NOT_FOUND',
  'GUARDIAN_NOT_FOUND',
  'ADMIN_NOT_FOUND',
  'SCHEDULE_ITEM_NOT_FOUND',
  'EMAIL_ALREADY_EXISTS',
  'KID_ALREADY_CHECKED_IN',
  'KID_NOT_CHECKED_IN',
  'SESSION_ALREADY_RESOLVED',
  'KID_NOT_ACTIVE',
  'CAPACITY_EXCEEDED',
  'SERVER_ERROR',
  'NETWORK_ERROR',
];

Map<String, dynamic> _translations(String locale) {
  final file = File('assets/translations/$locale.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

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

  group('translation coverage', () {
    for (final locale in ['en', 'ar']) {
      test('$locale.json has a key for every contract error code', () {
        final keys = _translations(locale).keys.toSet();
        final missing = _contractErrorCodes
            .map((code) => 'error_${code.toLowerCase()}')
            .where((key) => !keys.contains(key))
            .toList();

        expect(missing, isEmpty, reason: 'missing in $locale.json: $missing');
      });
    }

    test('en and ar define the same error keys', () {
      Set<String> errorKeys(String locale) =>
          _translations(locale).keys.where((k) => k.startsWith('error_')).toSet();

      expect(errorKeys('en'), errorKeys('ar'));
    });
  });
}
