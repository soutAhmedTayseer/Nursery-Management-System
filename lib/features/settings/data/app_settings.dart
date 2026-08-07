import 'package:flutter/material.dart';

/// Everything the Settings screen owns, in one immutable value.
///
/// Nursery figures (capacity, currency, overtime rate) live here rather
/// than as constants scattered through Finance and the Dashboard — they are
/// business policy an admin sets, not code.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.adminName = 'Admin',
    this.adminEmail = 'admin@wildwood.com',
    this.adminPhotoPath,
    this.nurseryName = 'Wildwood Nursery',
    this.capacity = 50,
    this.currency = 'AED',
    this.overtimeHourlyRate = 25,
    this.latePickupGraceMinutes = 15,
    this.latePickupFine = 50,
    this.openingHour = 7,
    this.closingHour = 17,
  });

  final ThemeMode themeMode;

  /// Multiplies every `.sp` size. Clamped by the Settings UI to a readable
  /// band rather than left open-ended.
  final double textScale;

  /// Stamped on every audit-log entry, so it has to be a real name once
  /// more than one person uses the app.
  final String adminName;
  final String adminEmail;
  final String? adminPhotoPath;

  final String nurseryName;
  final int capacity;
  final String currency;

  /// AED charged per hour a child stays past their plan.
  final double overtimeHourlyRate;

  /// Minutes past a child's allowed hours before the pickup counts as late.
  /// Traffic and a slow handover shouldn't fine a parent, so the hourly
  /// overtime charge starts immediately but the fine does not.
  final int latePickupGraceMinutes;

  /// Flat AED fine per day a child is collected late, on top of the hourly
  /// overtime. It is deliberately per-day rather than per-hour: the point is
  /// to discourage the habit, and an hourly figure already prices the time.
  final double latePickupFine;

  final int openingHour;
  final int closingHour;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? textScale,
    String? adminName,
    String? adminEmail,
    String? adminPhotoPath,
    String? nurseryName,
    int? capacity,
    String? currency,
    double? overtimeHourlyRate,
    int? latePickupGraceMinutes,
    double? latePickupFine,
    int? openingHour,
    int? closingHour,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPhotoPath: adminPhotoPath ?? this.adminPhotoPath,
      nurseryName: nurseryName ?? this.nurseryName,
      capacity: capacity ?? this.capacity,
      currency: currency ?? this.currency,
      overtimeHourlyRate: overtimeHourlyRate ?? this.overtimeHourlyRate,
      latePickupGraceMinutes: latePickupGraceMinutes ?? this.latePickupGraceMinutes,
      latePickupFine: latePickupFine ?? this.latePickupFine,
      openingHour: openingHour ?? this.openingHour,
      closingHour: closingHour ?? this.closingHour,
    );
  }

  Map<String, Object?> toJson() => {
        'themeMode': themeMode.name,
        'textScale': textScale,
        'adminName': adminName,
        'adminEmail': adminEmail,
        'adminPhotoPath': adminPhotoPath,
        'nurseryName': nurseryName,
        'capacity': capacity,
        'currency': currency,
        'overtimeHourlyRate': overtimeHourlyRate,
        'latePickupGraceMinutes': latePickupGraceMinutes,
        'latePickupFine': latePickupFine,
        'openingHour': openingHour,
        'closingHour': closingHour,
      };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      adminName: json['adminName'] as String? ?? 'Admin',
      adminEmail: json['adminEmail'] as String? ?? 'admin@wildwood.com',
      adminPhotoPath: json['adminPhotoPath'] as String?,
      nurseryName: json['nurseryName'] as String? ?? 'Wildwood Nursery',
      capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      currency: json['currency'] as String? ?? 'AED',
      overtimeHourlyRate: (json['overtimeHourlyRate'] as num?)?.toDouble() ?? 25,
      latePickupGraceMinutes: (json['latePickupGraceMinutes'] as num?)?.toInt() ?? 15,
      latePickupFine: (json['latePickupFine'] as num?)?.toDouble() ?? 50,
      openingHour: (json['openingHour'] as num?)?.toInt() ?? 7,
      closingHour: (json['closingHour'] as num?)?.toInt() ?? 17,
    );
  }
}
