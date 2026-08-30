import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  factory ApiException.fromDioError(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final errorMap = data['error'] as Map<String, dynamic>;
      return ApiException(
        code: errorMap['code'] as String? ?? 'UNKNOWN_ERROR',
        message: errorMap['message'] as String? ?? 'An unknown error occurred',
        statusCode: response?.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: error.message ?? 'Network error',
      statusCode: response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code, status: $statusCode): $message';
}
