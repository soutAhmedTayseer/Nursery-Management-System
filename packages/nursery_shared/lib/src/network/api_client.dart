import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokenStorage,
  }) : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      refreshTokens: _refreshTokens,
    ));
    // Added last so it sees the Authorization header the auth interceptor
    // attaches, and the final status after any refresh-and-retry.
    if (LoggingInterceptor.enabled) {
      dio.interceptors.add(LoggingInterceptor());
    }
  }

  final Dio dio;
  final TokenStorage tokenStorage;

  Future<bool> _refreshTokens(TokenStorage storage) async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
      ))..httpClientAdapter = dio.httpClientAdapter;
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data!;
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } on DioException {
      return false;
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _wrap(() => dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(
      () => dio.post<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(
      () => dio.put<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(
      () => dio.patch<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(
      () => dio.delete<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  /// Uploads [filePath] as `multipart/form-data` under [field].
  ///
  /// Content-Type is left to dio so it generates the multipart boundary.
  Future<Response<T>> postMultipart<T>(
    String path, {
    required String filePath,
    String field = 'file',
    Map<String, dynamic>? fields,
  }) async {
    final formData = FormData.fromMap({
      ...?fields,
      field: await MultipartFile.fromFile(filePath),
    });
    return _wrap(() => dio.post<T>(path, data: formData));
  }

  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
