/// Login, logout and session-presence for the admin app.
///
/// Implementations throw `ApiException` (nursery_shared) on a failed login —
/// nothing else. `FakeAuthRepository` backs the UI today; `ApiAuthRepository`
/// replaces it at integration by changing one line in `core/di/injection.dart`.
abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> logout();

  /// True when a token is already on disk — used by splash to skip login.
  Future<bool> hasSession();
}
