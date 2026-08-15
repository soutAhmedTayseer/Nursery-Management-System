import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';

/// In-app notification history and FCM device registration (contract §4
/// "Notifications / Devices").
///
/// Real-time is REST plus push-to-refresh, not a socket (contract §6): the
/// server pushes an event, the app refetches. So this is only the history
/// endpoint and the token registration either side of it.
abstract class NotificationsRepository {
  Future<List<AppNotification>> fetchNotifications();

  /// Registers this device for push. Called after login, once an FCM token
  /// exists.
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  });

  /// Called on logout so a shared machine stops receiving another admin's
  /// pushes.
  Future<void> unregisterDevice(String deviceToken);
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client)
      : _devices = DeviceService(_client);

  final ApiClient _client;
  final DeviceService _devices;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _client.get<Map<String, dynamic>>('/notifications');
    return PaginatedResult.fromJson(response.data!, AppNotification.fromJson)
        .items;
  }

  @override
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  }) =>
      _devices.registerDevice(deviceToken: deviceToken, platform: platform);

  @override
  Future<void> unregisterDevice(String deviceToken) =>
      _devices.unregisterDevice(deviceToken);
}

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository({required this.failureSwitch});

  final FakeFailureSwitch failureSwitch;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    failureSwitch.maybeThrow();
    return const [];
  }

  @override
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  }) async {}

  @override
  Future<void> unregisterDevice(String deviceToken) async {}
}
