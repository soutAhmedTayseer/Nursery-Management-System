import 'package:nursery_shared/nursery_shared.dart';

/// Dev-only toggle that makes the next fake repository call fail.
///
/// Exists so error UI is built and verified now rather than discovered missing
/// on integration day. Registered in `get_it`; a debug menu flips it.
class FakeFailureSwitch {
  FakeFailureSwitch({this.enabled = false});

  bool enabled;

  ApiException get exception => const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Forced failure from FakeFailureSwitch',
        statusCode: null,
      );

  /// Call at the top of every fake repository method.
  void maybeThrow() {
    if (enabled) throw exception;
  }
}
