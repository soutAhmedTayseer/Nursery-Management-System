import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../fakes/fake_token_storage.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(body));
    return ResponseBody.fromBytes(bytes, statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

class _UnauthorizedThenRefreshAdapter implements HttpClientAdapter {
  int pingCallCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      // Backend omits `refresh_token` — spec only promises a new access token.
      final body = utf8.encode(jsonEncode({'access_token': 'new-token'}));
      return ResponseBody.fromBytes(body, 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
    }

    pingCallCount++;
    if (pingCallCount == 1) {
      final body = utf8.encode(jsonEncode({
        'error': {'code': 'UNAUTHORIZED', 'message': 'Token expired'},
      }));
      return ResponseBody.fromBytes(body, 401, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
    }

    final body = utf8.encode(jsonEncode({'ok': true}));
    return ResponseBody.fromBytes(body, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

class _QueryRecordingAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastQuery;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastQuery = options.queryParameters;
    final bytes = utf8.encode(jsonEncode({'ok': true}));
    return ResponseBody.fromBytes(bytes, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

void main() {
  test('GET returns decoded data on success', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 't'),
    );
    client.dio.httpClientAdapter = _StubAdapter(200, {'id': 'k1'});

    final response = await client.get<Map<String, dynamic>>('/kids/k1');

    expect(response.data!['id'], 'k1');
  });

  test('throws ApiException with the backend error code on failure', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 't'),
    );
    client.dio.httpClientAdapter = _StubAdapter(404, {
      'error': {'code': 'KID_NOT_FOUND', 'message': 'Kid not found'},
    });

    await expectLater(
      client.get<Map<String, dynamic>>('/kids/999'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'KID_NOT_FOUND'),
      ),
    );
  });

  test(
      'refreshes and retries successfully when /auth/refresh omits refresh_token',
      () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1'),
    );
    client.dio.httpClientAdapter = _UnauthorizedThenRefreshAdapter();

    final response = await client.get<Map<String, dynamic>>('/ping');

    expect(response.data!['ok'], true);
    expect(await client.tokenStorage.readAccessToken(), 'new-token');
    // Falls back to the existing refresh token since the backend didn't rotate it.
    expect(await client.tokenStorage.readRefreshToken(), 'refresh-1');
  });

  test('write verbs send query parameters', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: FakeTokenStorage(accessToken: 't'),
    );
    final adapter = _QueryRecordingAdapter();
    client.dio.httpClientAdapter = adapter;

    await client.post<dynamic>('/a', queryParameters: {'status': 'pending'});
    expect(adapter.lastQuery, {'status': 'pending'});

    await client.patch<dynamic>('/b', queryParameters: {'page': 2});
    expect(adapter.lastQuery, {'page': 2});

    await client.delete<dynamic>('/c', queryParameters: {'force': true});
    expect(adapter.lastQuery, {'force': true});
  });
}
