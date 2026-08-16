import 'package:nursery_shared/nursery_shared.dart';

/// The nursery-wide policy an admin configures (contract §2 NurserySettings).
///
/// Deliberately narrower than the app's `AppSettings`, which also carries theme
/// and text scale. Those are device preferences and stay in local storage — an
/// admin's dark-mode choice is not nursery policy and should not follow them to
/// another machine, nor be visible to other admins.
class NurserySettings {
  const NurserySettings({
    required this.capacity,
    required this.opensAt,
    required this.closesAt,
    required this.currency,
    required this.latePickupGraceMinutes,
    required this.latePickupRate,
    required this.overtimeHourlyRate,
    required this.lowBalanceThresholdHours,
  });

  final int capacity;

  /// `HH:mm`.
  final String opensAt;
  final String closesAt;

  final String currency;
  final int latePickupGraceMinutes;
  final double latePickupRate;
  final double overtimeHourlyRate;
  final double lowBalanceThresholdHours;

  factory NurserySettings.fromJson(Map<String, dynamic> json) => NurserySettings(
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        opensAt: json['opens_at'] as String? ?? '07:00',
        closesAt: json['closes_at'] as String? ?? '17:00',
        currency: json['currency'] as String? ?? 'AED',
        latePickupGraceMinutes:
            (json['late_pickup_grace_minutes'] as num?)?.toInt() ?? 0,
        latePickupRate: (json['late_pickup_rate'] as num?)?.toDouble() ?? 0,
        overtimeHourlyRate:
            (json['overtime_hourly_rate'] as num?)?.toDouble() ?? 0,
        lowBalanceThresholdHours:
            (json['low_balance_threshold_hours'] as num?)?.toDouble() ?? 0,
      );
}

abstract class SettingsRepository {
  Future<NurserySettings> fetchSettings();

  /// Patches only the fields given — the endpoint accepts any subset.
  Future<NurserySettings> updateSettings({
    int? capacity,
    String? opensAt,
    String? closesAt,
    String? currency,
    int? latePickupGraceMinutes,
    double? latePickupRate,
    double? overtimeHourlyRate,
    double? lowBalanceThresholdHours,
  });

  /// The signed-in admin's own profile.
  Future<Admin> fetchProfile();

  Future<Admin> updateProfile({String? fullName, String? email});
}
