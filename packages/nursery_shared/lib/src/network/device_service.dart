import 'api_client.dart';

class DeviceService {
  DeviceService(this._client);

  final ApiClient _client;

  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  }) {
    return _client.post<void>('/devices', data: {
      'device_token': deviceToken,
      'platform': platform,
    });
  }

  Future<void> unregisterDevice(String deviceToken) {
    return _client.delete<void>('/devices/$deviceToken');
  }
}
