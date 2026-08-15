import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/notifications/data/repositories/notifications_repository.dart';
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

void main() {
  late _StubAdapter adapter;
  late ApiNotificationsRepository repository;

  setUp(() {
    adapter = _StubAdapter();
    final client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
    repository = ApiNotificationsRepository(client);
  });

  test('fetchNotifications unwraps the paginated envelope', () async {
    adapter.body = {
      'items': [
        {
          'id': 'ntf_01',
          'recipient_id': 'adm_01',
          'recipient_type': 'admin',
          'type': 'checkin_requested',
          'payload': {'kid_id': 'kid_01'},
          'sent_at': '2026-08-15T07:30:00Z',
          'read_at': null,
        },
      ],
      'total': 15,
      'page': 1,
      'page_size': 20,
    };

    final notifications = await repository.fetchNotifications();

    expect(adapter.paths.single, '/notifications');
    expect(notifications.single.type, 'checkin_requested');
  });

  test('registerDevice posts the token and platform', () async {
    await repository.registerDevice(deviceToken: 'fcm-token', platform: 'windows');

    expect(adapter.paths.single, '/devices');
    expect(adapter.bodies.single, {
      'device_token': 'fcm-token',
      'platform': 'windows',
    });
  });

  test('unregisterDevice deletes the token', () async {
    await repository.unregisterDevice('fcm-token');

    expect(adapter.methods.single, 'DELETE');
    expect(adapter.paths.single, '/devices/fcm-token');
  });
}
