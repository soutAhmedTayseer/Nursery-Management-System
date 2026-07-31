import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/testing/fake_failure_switch.dart';
import 'package:nursery_management_system/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _InMemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;
  @override
  Future<String?> readRefreshToken() async => refresh;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    access = accessToken;
    refresh = refreshToken;
  }
  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

void main() {
  late _InMemoryTokenStorage storage;
  late FakeFailureSwitch failureSwitch;
  late FakeAuthRepository repository;

  setUp(() {
    storage = _InMemoryTokenStorage();
    failureSwitch = FakeFailureSwitch();
    repository = FakeAuthRepository(
      tokenStorage: storage,
      failureSwitch: failureSwitch,
      latency: Duration.zero,
    );
  });

  test('login persists a token and hasSession becomes true', () async {
    expect(await repository.hasSession(), isFalse);
    await repository.login(email: 'admin@wildwood.com', password: 'secret');
    expect(await repository.hasSession(), isTrue);
    expect(storage.access, isNotNull);
  });

  test('login throws ApiException when the failure switch is on', () async {
    failureSwitch.enabled = true;
    expect(
      () => repository.login(email: 'admin@wildwood.com', password: 'secret'),
      throwsA(isA<ApiException>()),
    );
    expect(await repository.hasSession(), isFalse);
  });

  test('logout clears the token and hasSession becomes false', () async {
    await repository.login(email: 'admin@wildwood.com', password: 'secret');
    await repository.logout();
    expect(await repository.hasSession(), isFalse);
  });

  test('hasSession is true when a token already exists on disk', () async {
    storage.access = 'existing-token';
    expect(await repository.hasSession(), isTrue);
  });
}
