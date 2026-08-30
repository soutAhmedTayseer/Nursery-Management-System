import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/auth/data/repositories/api_auth_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _InMemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;
  @override
  Future<String?> readRefreshToken() async => refresh;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.replies);

  final Map<String, (int, Map<String, dynamic>)> replies;
  final List<String> pathsCalled = [];
  final Map<String, Object?> lastBodyByPath = {};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    pathsCalled.add(options.path);
    final data = options.data;
    lastBodyByPath[options.path] =
        data is String ? jsonDecode(data) : data;
    final reply = replies[options.path];
    if (reply == null) throw StateError('no stub for ${options.path}');
    final (status, body) = reply;
    return ResponseBody.fromBytes(utf8.encode(jsonEncode(body)), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _superAdminBody = {
  'userId': 'a0bb80f8',
  'userName': 'superadmin',
  'fullName': 'ahmed tayseer',
  'role': 'SuperAdmin',
  'accessToken': 'access-1',
  'refreshToken': 'refresh-1',
  'refreshTokenExpiresAt': '2026-09-06T10:00:40Z',
};

void main() {
  late _InMemoryTokenStorage storage;

  ApiAuthRepository repositoryWith(_StubAdapter adapter) {
    storage = _InMemoryTokenStorage();
    final client = ApiClient(baseUrl: 'https://api.test', tokenStorage: storage)
      ..dio.httpClientAdapter = adapter;
    return ApiAuthRepository(client: client, tokenStorage: storage);
  }

  group('login', () {
    test('sends the credential as userName and stores both tokens', () async {
      final adapter = _StubAdapter({'/auth/login': (200, _superAdminBody)});
      final repository = repositoryWith(adapter);

      await repository.login(email: 'superadmin', password: 'pw');

      expect(adapter.lastBodyByPath['/auth/login'],
          {'userName': 'superadmin', 'password': 'pw'});
      expect(storage.access, 'access-1');
      expect(storage.refresh, 'refresh-1');
      expect(await repository.hasSession(), isTrue);
    });

    test('rejects a parent role and saves nothing', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (200, {
          ..._superAdminBody,
          'role': 'Parent',
        }),
      }));

      await expectLater(
        () => repository.login(email: 'parent@example.com', password: 'pw'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FORBIDDEN')),
      );
      expect(storage.access, isNull);
      expect(await repository.hasSession(), isFalse);
    });

    test('propagates the backend error code and saves nothing', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (401, {
          'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Wrong username or password'},
        }),
      }));

      await expectLater(
        () => repository.login(email: 'superadmin', password: 'wrong'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')),
      );
      expect(storage.access, isNull);
    });
  });

  group('logout', () {
    test('revokes the refresh token and clears storage', () async {
      final adapter = _StubAdapter({
        '/auth/login': (200, _superAdminBody),
        '/auth/revoke': (204, const <String, dynamic>{}),
      });
      final repository = repositoryWith(adapter);
      await repository.login(email: 'superadmin', password: 'pw');

      await repository.logout();

      expect(adapter.lastBodyByPath['/auth/revoke'], {'refreshToken': 'refresh-1'});
      expect(storage.access, isNull);
      expect(storage.refresh, isNull);
    });

    test('still clears storage when revoke fails', () async {
      final adapter = _StubAdapter({
        '/auth/login': (200, _superAdminBody),
        '/auth/revoke': (500, {
          'error': {'code': 'SERVER_ERROR', 'message': 'boom'},
        }),
      });
      final repository = repositoryWith(adapter);
      await repository.login(email: 'superadmin', password: 'pw');

      await repository.logout();

      expect(storage.access, isNull);
      expect(await repository.hasSession(), isFalse);
    });
  });
}
