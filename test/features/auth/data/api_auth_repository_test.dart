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

/// Replies with a canned body per path, and records what was asked for.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.replies);

  /// path -> (status, body)
  final Map<String, (int, Map<String, dynamic>)> replies;
  final List<String> pathsCalled = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    pathsCalled.add(options.path);
    final reply = replies[options.path];
    if (reply == null) throw StateError('no stub for ${options.path}');

    final (status, body) = reply;
    return ResponseBody.fromBytes(utf8.encode(jsonEncode(body)), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _adminLoginBody = {
  'admin': {'id': 'adm_01', 'full_name': 'Nadia', 'email': 'nadia@nursery.example'},
  'role': 'admin',
  'access_token': 'access-1',
  'refresh_token': 'refresh-1',
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
    test('saves both tokens on an admin login', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (200, _adminLoginBody),
      }));

      await repository.login(email: 'nadia@nursery.example', password: 'pw');

      expect(storage.access, 'access-1');
      expect(storage.refresh, 'refresh-1');
      expect(await repository.hasSession(), isTrue);
    });

    test('rejects a guardian and saves nothing', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (200, {
          'guardian': {'id': 'gdn_01'},
          'role': 'guardian',
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
        }),
      }));

      await expectLater(
        () => repository.login(email: 'layla@example.com', password: 'pw'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FORBIDDEN')),
      );
      // The point of the check: no usable session is left behind.
      expect(storage.access, isNull);
      expect(await repository.hasSession(), isFalse);
    });

    test('propagates the backend error code and saves nothing', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (401, {
          'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Wrong email or password'},
        }),
      }));

      await expectLater(
        () => repository.login(email: 'nadia@nursery.example', password: 'wrong'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')),
      );
      expect(storage.access, isNull);
    });
  });

  group('logout', () {
    test('revokes server-side and clears storage', () async {
      final adapter = _StubAdapter({
        '/auth/login': (200, _adminLoginBody),
        '/auth/logout': (204, <String, dynamic>{}),
      });
      final repository = repositoryWith(adapter);
      await repository.login(email: 'nadia@nursery.example', password: 'pw');

      await repository.logout();

      expect(adapter.pathsCalled, contains('/auth/logout'));
      expect(await repository.hasSession(), isFalse);
    });

    test('clears storage even when the server call fails', () async {
      final repository = repositoryWith(_StubAdapter({
        '/auth/login': (200, _adminLoginBody),
        '/auth/logout': (500, {
          'error': {'code': 'SERVER_ERROR', 'message': 'boom'},
        }),
      }));
      await repository.login(email: 'nadia@nursery.example', password: 'pw');

      // Must not throw: an unreachable server cannot strand the user in a
      // session they explicitly ended.
      await repository.logout();

      expect(storage.access, isNull);
      expect(storage.refresh, isNull);
    });

    test('clears storage when there is no refresh token to revoke', () async {
      final adapter = _StubAdapter({});
      final repository = repositoryWith(adapter);
      storage.access = 'orphan-access-token';

      await repository.logout();

      expect(adapter.pathsCalled, isEmpty);
      expect(await repository.hasSession(), isFalse);
    });
  });

  test('hasSession reflects what is on disk', () async {
    final repository = repositoryWith(_StubAdapter({}));

    expect(await repository.hasSession(), isFalse);
    storage.access = 'existing-token';
    expect(await repository.hasSession(), isTrue);
  });
}
