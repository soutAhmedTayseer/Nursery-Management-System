import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('maps a backend error envelope response to ApiException', () {
    final requestOptions = RequestOptions(path: '/kids/999');
    final dioError = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 404,
        data: {
          'error': {'code': 'KID_NOT_FOUND', 'message': 'Kid not found'},
        },
      ),
    );

    final exception = ApiException.fromDioError(dioError);

    expect(exception.code, 'KID_NOT_FOUND');
    expect(exception.message, 'Kid not found');
    expect(exception.statusCode, 404);
  });

  test('falls back to NETWORK_ERROR when there is no response (e.g. timeout)', () {
    final requestOptions = RequestOptions(path: '/kids');
    final dioError = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.connectionTimeout,
      message: 'Connection timed out',
    );

    final exception = ApiException.fromDioError(dioError);

    expect(exception.code, 'NETWORK_ERROR');
    expect(exception.statusCode, isNull);
  });
}
