import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nursery_management_system/features/settings/data/repositories/api_settings_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _NoTokens implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
  @override
  Future<void> clear() async {}
}

class _StubAdapter implements HttpClientAdapter {
  int status = 200;
  Map<String, dynamic> body = const {};

  final List<String> paths = [];
  final List<String> methods = [];
  final List<dynamic> bodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    methods.add(options.method);
    bodies.add(options.data);

    return ResponseBody.fromBytes(utf8.encode(jsonEncode(body)), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _settingsJson = {
  'capacity': 45,
  'opens_at': '07:00',
  'closes_at': '18:00',
  'currency': 'AED',
  'late_pickup_grace_minutes': 15,
  'late_pickup_rate': 25,
  'overtime_hourly_rate': 60,
  'low_balance_threshold_hours': 2,
};

void main() {
  late _StubAdapter adapter;
  late ApiClient client;
  late ApiSettingsRepository repository;

  setUp(() {
    adapter = _StubAdapter();
    client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
    repository = ApiSettingsRepository(client);
  });

  test('fetchSettings decodes the nursery policy', () async {
    adapter.body = Map<String, dynamic>.from(_settingsJson);

    final settings = await repository.fetchSettings();

    expect(adapter.paths.single, '/admin/settings');
    expect(settings.capacity, 45);
    expect(settings.closesAt, '18:00');
    expect(settings.overtimeHourlyRate, 60);
  });

  test('updateSettings sends only the fields given', () async {
    adapter.body = Map<String, dynamic>.from(_settingsJson);

    await repository.updateSettings(capacity: 60);

    expect(adapter.methods.single, 'PATCH');
    // A PATCH must not blank policy the admin never touched.
    expect(adapter.bodies.single, {'capacity': 60});
  });

  test('fetchProfile reads the signed-in admin', () async {
    adapter.body = {
      'id': 'adm_01',
      'full_name': 'Nadia Farouk',
      'email': 'nadia@nursery.example',
      'created_at': '2025-11-02T06:00:00Z',
    };

    final profile = await repository.fetchProfile();

    expect(adapter.paths.single, '/admin/me');
    expect(profile.fullName, 'Nadia Farouk');
  });

  test('a rejected settings write surfaces', () async {
    adapter
      ..status = 403
      ..body = {
        'error': {'code': 'FORBIDDEN', 'message': 'Admin role required'},
      };

    await expectLater(
      () => repository.updateSettings(capacity: 10),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FORBIDDEN')),
    );
  });

  test('dashboard stats come from one call', () async {
    adapter.body = {
      'occupancy': 23,
      'capacity': 40,
      'pending_approvals_count': 3,
      'pending_session_requests_count': 4,
      'revenue_month_to_date': 48200,
      'total_outstanding': 3150,
      'expiring_subscriptions_count': 5,
      'low_balance_count': 2,
    };

    final stats = await ApiDashboardRepository(client).fetchStats();

    expect(adapter.paths.single, '/admin/dashboard');
    expect(stats.occupancy, 23);
    expect(stats.pendingApprovalsCount, 3);
    expect(stats.totalOutstanding, 3150);
  });
}
