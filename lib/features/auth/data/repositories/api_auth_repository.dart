import 'package:nursery_shared/nursery_shared.dart';

import 'auth_repository.dart';

/// Talks to the live API's `/auth/*` routes.
///
/// `POST /auth/login` is shared by both apps and resolves the role
/// server-side. The credential entered on the admin login screen is sent as
/// `userName`.
///
/// A non-admin who signs in here is rejected before any token reaches disk,
/// so a guardian gets a clear message instead of an app full of empty
/// screens. That check is a convenience, not a security boundary — the
/// server rejects cross-role calls regardless.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required this.client, required this.tokenStorage});

  final ApiClient client;
  final TokenStorage tokenStorage;

  static const _parentRoles = {'parent', 'guardian'};

  @override
  Future<void> login({required String email, required String password}) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'userName': email, 'password': password},
    );
    await _acceptAdminSession(response.data ?? const <String, dynamic>{});
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    try {
      if (refreshToken != null) {
        await client.post<dynamic>(
          '/auth/revoke',
          data: {'refreshToken': refreshToken},
        );
      }
    } on ApiException {
      // Server-side revocation is best-effort. Leaving a token on disk because
      // the server was unreachable would strand the user in a session they
      // explicitly ended, which is worse than a stale token the server will
      // expire on its own.
    } finally {
      await tokenStorage.clear();
    }
  }

  @override
  Future<bool> hasSession() async =>
      (await tokenStorage.readAccessToken()) != null;

  /// Saves tokens only for an admin-side role. A parent who authenticates
  /// here must not end up with a usable session in the admin app.
  Future<void> _acceptAdminSession(Map<String, dynamic> body) async {
    final role = (body['role'] as String?)?.toLowerCase();
    if (role == null || _parentRoles.contains(role)) {
      throw const ApiException(
        code: 'FORBIDDEN',
        message: 'This account cannot sign in to the admin app',
        statusCode: 403,
      );
    }

    await tokenStorage.saveTokens(
      accessToken: body['accessToken'] as String,
      refreshToken: body['refreshToken'] as String,
    );
  }
}
