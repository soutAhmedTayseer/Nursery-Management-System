import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../fakes/fake_token_storage.dart';

class _RecordingAdapter implements HttpClientAdapter {
  int callCount = 0;
  final List<String?> authHeadersSeen = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    authHeadersSeen.add(options.headers['Authorization'] as String?);

    if (options.headers['Authorization'] == 'Bearer old-token') {
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

void main() {
  test('attaches the current access token as a Bearer header', () async {
    final storage = FakeTokenStorage(accessToken: 'valid-token');
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (_) async => false,
    ));

    await dio.get<dynamic>('/ping');

    expect(adapter.authHeadersSeen.single, 'Bearer valid-token');
  });

  test('on 401, calls refreshTokens and retries the request once with the new token', () async {
    final storage = FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1');
    final adapter = _RecordingAdapter();
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (s) async {
        refreshCalls++;
        await s.saveTokens(accessToken: 'new-token', refreshToken: 'refresh-2');
        return true;
      },
    ));

    final response = await dio.get<dynamic>('/ping');

    expect(refreshCalls, 1);
    expect(adapter.callCount, 2);
    expect(adapter.authHeadersSeen, ['Bearer old-token', 'Bearer new-token']);
    expect(response.statusCode, 200);
  });

  test('on 401 with a failed refresh, surfaces the original error', () async {
    final storage = FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1');
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (_) async => false,
    ));

    await expectLater(
      dio.get<dynamic>('/ping'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.callCount, 1);
  });

  test('on 401 even after a successful refresh, retries only once and surfaces the error', () async {
    final storage = FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1');
    final adapter = _AlwaysUnauthorizedAdapter();
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (s) async {
        refreshCalls++;
        await s.saveTokens(accessToken: 'new-token', refreshToken: 'refresh-2');
        return true;
      },
    ));

    await expectLater(
      dio.get<dynamic>('/ping'),
      throwsA(isA<DioException>()),
    );

    expect(refreshCalls, 1);
    expect(adapter.callCount, 2);
  });

  test('concurrent 401s share one refresh instead of racing', () async {
    final storage = FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1');
    final adapter = _RecordingAdapter();
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (s) async {
        refreshCalls++;
        // A real refresh is not instant; the delay lets all three 401s arrive
        // while this one is still in flight, which is the case being tested.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await s.saveTokens(accessToken: 'new-token', refreshToken: 'refresh-2');
        return true;
      },
    ));

    final responses = await Future.wait([
      dio.get<dynamic>('/a'),
      dio.get<dynamic>('/b'),
      dio.get<dynamic>('/c'),
    ]);

    expect(refreshCalls, 1, reason: 'three parallel 401s must not refresh three times');
    expect(responses.every((r) => r.statusCode == 200), isTrue);
  });

  test('refresh is not cached across separate 401s', () async {
    final storage = FakeTokenStorage(accessToken: 'old-token', refreshToken: 'refresh-1');
    final adapter = _RecordingAdapter();
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      refreshTokens: (s) async {
        refreshCalls++;
        await s.saveTokens(accessToken: 'new-token', refreshToken: 'refresh-2');
        return true;
      },
    ));

    await dio.get<dynamic>('/a');
    // Token goes stale again — the second 401 must start a fresh refresh, not
    // reuse the completed future from the first.
    await storage.saveTokens(accessToken: 'old-token', refreshToken: 'refresh-2');
    await dio.get<dynamic>('/b');

    expect(refreshCalls, 2);
  });
}

class _AlwaysUnauthorizedAdapter implements HttpClientAdapter {
  int callCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    final body = utf8.encode(jsonEncode({
      'error': {'code': 'UNAUTHORIZED', 'message': 'Token expired'},
    }));
    return ResponseBody.fromBytes(body, 401, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}
