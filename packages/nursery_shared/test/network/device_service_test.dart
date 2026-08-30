import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../fakes/fake_token_storage.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  dynamic lastRequestBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastRequestBody = options.data;
    final body = utf8.encode(jsonEncode({}));
    return ResponseBody.fromBytes(body, 204, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

void main() {
  test('registerDevice POSTs the device token and platform to /devices', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 't'),
    );
    final adapter = _CapturingAdapter();
    client.dio.httpClientAdapter = adapter;
    final service = DeviceService(client);

    await service.registerDevice(deviceToken: 'fcm-token-1', platform: 'android');

    expect(adapter.lastRequest!.path, '/devices');
    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequestBody, {
      'device_token': 'fcm-token-1',
      'platform': 'android',
    });
  });

  test('unregisterDevice DELETEs /devices/{token}', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 't'),
    );
    final adapter = _CapturingAdapter();
    client.dio.httpClientAdapter = adapter;
    final service = DeviceService(client);

    await service.unregisterDevice('fcm-token-1');

    expect(adapter.lastRequest!.path, '/devices/fcm-token-1');
    expect(adapter.lastRequest!.method, 'DELETE');
  });
}
