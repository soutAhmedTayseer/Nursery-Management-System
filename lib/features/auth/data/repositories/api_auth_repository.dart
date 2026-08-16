import 'package:nursery_shared/nursery_shared.dart';

import 'auth_repository.dart';

/// Talks to `/auth/*` (contract §4).
///
/// `POST /auth/login` is shared by both apps and resolves the role server-side,
/// so a guardian can present valid credentials here. This rejects them before
/// any token reaches disk — see [login]. That check is a convenience, not a
/// security boundary: every `/admin/*` endpoint rejects non-admin tokens
/// server-side (contract §5), which is what actually protects the data.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required this.client, required this.tokenStorage});

  final ApiClient client;
  final TokenStorage tokenStorage;

  @override
  Future<void> login({required String email, required String password}) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final body = response.data ?? const <String, dynamic>{};

    if (body['role'] != 'admin') {
      // Saving nothing is the point: a guardian who logs in here must not end
      // up with a usable session in the admin app.
      throw const ApiException(
        code: 'FORBIDDEN',
        message: 'This account is not an admin',
        statusCode: 403,
      );
    }

    await tokenStorage.saveTokens(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.readRefreshToken();

    try {
      if (refreshToken != null) {
        await client.post<dynamic>(
          '/auth/logout',
          data: {'refresh_token': refreshToken},
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
}
