import 'package:nursery_shared/nursery_shared.dart';

import 'settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  ApiSettingsRepository(this._client);

  final ApiClient _client;

  @override
  Future<NurserySettings> fetchSettings() async {
    final response =
        await _client.get<Map<String, dynamic>>('/admin/settings');
    return NurserySettings.fromJson(response.data!);
  }

  @override
  Future<NurserySettings> updateSettings({
    int? capacity,
    String? opensAt,
    String? closesAt,
    String? currency,
    int? latePickupGraceMinutes,
    double? latePickupRate,
    double? overtimeHourlyRate,
    double? lowBalanceThresholdHours,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/settings',
      data: {
        'capacity': ?capacity,
        'opens_at': ?opensAt,
        'closes_at': ?closesAt,
        'currency': ?currency,
        'late_pickup_grace_minutes': ?latePickupGraceMinutes,
        'late_pickup_rate': ?latePickupRate,
        'overtime_hourly_rate': ?overtimeHourlyRate,
        'low_balance_threshold_hours': ?lowBalanceThresholdHours,
      },
    );
    return NurserySettings.fromJson(response.data!);
  }

  @override
  Future<Admin> fetchProfile() async {
    final response = await _client.get<Map<String, dynamic>>('/admin/me');
    return Admin.fromJson(response.data!);
  }

  @override
  Future<Admin> updateProfile({String? fullName, String? email}) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/me',
      data: {'full_name': ?fullName, 'email': ?email},
    );
    return Admin.fromJson(response.data!);
  }
}
