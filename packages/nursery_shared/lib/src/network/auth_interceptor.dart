import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.refreshTokens,
  });

  final Dio dio;
  final TokenStorage tokenStorage;
  final Future<bool> Function(TokenStorage storage) refreshTokens;

  /// The refresh currently in flight, if any.
  ///
  /// Several requests can 401 at once (any screen that fires parallel calls on
  /// resume). Without this, each one starts its own refresh; when the server
  /// rotates refresh tokens on use — which the contract allows, since they are
  /// revocable — the first refresh invalidates the token the others are still
  /// holding, so all but one fail and the user is bounced to login. Sharing one
  /// future means concurrent 401s await the same refresh instead.
  Future<bool>? _inFlightRefresh;

  Future<bool> _refreshOnce() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final started = refreshTokens(tokenStorage).whenComplete(() {
      _inFlightRefresh = null;
    });
    _inFlightRefresh = started;
    return started;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra['nursery_retried'] == true) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final newToken = await tokenStorage.readAccessToken();
    final retryOptions = err.requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $newToken';
    retryOptions.extra['nursery_retried'] = true;

    try {
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
