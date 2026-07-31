import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import 'auth_repository.dart';

/// Accepts any non-empty credentials; fails only when [failureSwitch] is on.
/// A fake credential database would be unneeded complexity for a fake.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.tokenStorage,
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 400),
  });

  final TokenStorage tokenStorage;
  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  @override
  Future<void> login({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
    await tokenStorage.saveTokens(
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
    );
  }

  @override
  Future<void> logout() => tokenStorage.clear();

  @override
  Future<bool> hasSession() async => (await tokenStorage.readAccessToken()) != null;
}
