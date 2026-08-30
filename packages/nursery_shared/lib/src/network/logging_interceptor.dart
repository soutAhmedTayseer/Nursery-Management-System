import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs every request and response so it is obvious what the app actually sent
/// and what came back.
///
/// On by default in debug builds; `--dart-define=API_LOGGING=false` silences it.
/// It never runs in release — see [enabled].
///
/// Bodies are truncated and the Authorization header is redacted: a log line is
/// the easiest place to leak a bearer token into a screenshot or a pasted
/// terminal dump.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.maxBodyChars = 1000});

  /// Longer bodies are cut off — a 200-kid roster in the console helps nobody.
  final int maxBodyChars;

  /// Debug builds only, unless explicitly disabled.
  static bool get enabled {
    const disabled = bool.fromEnvironment('API_LOGGING', defaultValue: true) == false;
    if (disabled) return false;
    var inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    return inDebug;
  }

  final _stopwatches = <RequestOptions, Stopwatch>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _stopwatches[options] = Stopwatch()..start();

    final query = options.queryParameters.isEmpty
        ? ''
        : '?${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    _log('--> ${options.method} ${options.path}$query');

    final auth = options.headers['Authorization'];
    if (auth is String && auth.isNotEmpty) {
      // Never print the token itself.
      _log('    auth: Bearer <${auth.length - 7} chars>');
    }
    if (options.data != null) {
      _log('    body: ${_body(options.data)}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final elapsed = _elapsed(response.requestOptions);
    _log(
      '<-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}$elapsed',
    );
    if (response.data != null) {
      _log('    ${_body(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final elapsed = _elapsed(options);
    final status = err.response?.statusCode;

    if (status == null) {
      // No response at all — almost always the server not running, which is
      // the single most common confusion when testing against the mock.
      _log('<-- FAILED ${options.method} ${options.path}$elapsed');
      _log('    ${err.type.name}: ${err.message}');
      _log('    (nothing answered on ${options.baseUrl} — is the server running?)');
    } else {
      _log('<-- $status ${options.method} ${options.path}$elapsed');
      if (err.response?.data != null) {
        _log('    ${_body(err.response!.data)}');
      }
    }

    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final stopwatch = _stopwatches.remove(options);
    return stopwatch == null ? '' : ' (${stopwatch.elapsedMilliseconds}ms)';
  }

  String _body(Object? data) {
    if (data is FormData) {
      return 'multipart: ${data.files.map((f) => f.key).join(', ')}';
    }
    var text = data is String ? data : _encode(data);
    if (text.length > maxBodyChars) {
      text = '${text.substring(0, maxBodyChars)}… (${text.length} chars)';
    }
    return text;
  }

  static String _encode(Object? data) {
    try {
      return jsonEncode(data);
    } on Object {
      return data.toString();
    }
  }

  /// Uses [debugPrint] rather than `dart:developer`'s `log`, because that one
  /// goes to the VM service only — it shows in the `flutter run` console but
  /// never reaches Android logcat, which is where you actually look when
  /// running on a device. `debugPrint` reaches both, and throttles output so
  /// Android's log buffer does not silently drop lines.
  ///
  /// The tag is part of the message, not a logcat tag: everything Flutter
  /// prints arrives under the `flutter` tag, so filter logcat on the text
  /// `nursery.api` instead.
  static void _log(String message) => debugPrint('[nursery.api] $message');
}
