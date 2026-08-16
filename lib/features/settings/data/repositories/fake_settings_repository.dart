import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import '../app_settings.dart';
import 'settings_repository.dart';

/// In-memory [SettingsRepository] seeded from [AppSettings]' defaults, so the
/// offline build opens with the same nursery policy it always had.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 200),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  static const _defaults = AppSettings();

  NurserySettings _settings = const NurserySettings(
    capacity: 50,
    opensAt: '07:00',
    closesAt: '17:00',
    currency: 'AED',
    latePickupGraceMinutes: 15,
    latePickupRate: 50,
    overtimeHourlyRate: 25,
    lowBalanceThresholdHours: 2,
  );

  Admin _profile = Admin(
    id: 'admin-1',
    fullName: _defaults.adminName,
    email: _defaults.adminEmail,
    createdAt: DateTime(2025, 11, 2),
  );

  @override
  Future<NurserySettings> fetchSettings() async {
    await _tick();
    return _settings;
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
    await _tick();
    _settings = NurserySettings(
      capacity: capacity ?? _settings.capacity,
      opensAt: opensAt ?? _settings.opensAt,
      closesAt: closesAt ?? _settings.closesAt,
      currency: currency ?? _settings.currency,
      latePickupGraceMinutes:
          latePickupGraceMinutes ?? _settings.latePickupGraceMinutes,
      latePickupRate: latePickupRate ?? _settings.latePickupRate,
      overtimeHourlyRate: overtimeHourlyRate ?? _settings.overtimeHourlyRate,
      lowBalanceThresholdHours:
          lowBalanceThresholdHours ?? _settings.lowBalanceThresholdHours,
    );
    return _settings;
  }

  @override
  Future<Admin> fetchProfile() async {
    await _tick();
    return _profile;
  }

  @override
  Future<Admin> updateProfile({String? fullName, String? email}) async {
    await _tick();
    _profile = Admin(
      id: _profile.id,
      fullName: fullName ?? _profile.fullName,
      email: email ?? _profile.email,
      createdAt: _profile.createdAt,
    );
    return _profile;
  }

  Future<void> _tick() async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
  }
}
