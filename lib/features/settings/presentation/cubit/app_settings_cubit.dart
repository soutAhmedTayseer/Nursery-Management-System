import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nursery_shared/nursery_shared.dart';

import '../../data/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

/// Owns every admin-configurable preference and writes each change to disk.
///
/// Settings are the one thing that must outlive a restart even in the demo
/// build — an admin who picks dark mode and finds it light again next
/// launch will assume the toggle is broken.
class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit([this._repository]) : super(const AppSettings());

  /// Null in tests and during early boot, where local preferences are enough.
  final SettingsRepository? _repository;

  static const _key = 'app_settings';

  /// Loads persisted settings. Call once at startup, before the first frame,
  /// so the app doesn't flash the wrong theme.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      emit(AppSettings.fromJson(jsonDecode(raw) as Map<String, Object?>));
    } on FormatException {
      // A settings blob written by an older build isn't worth crashing over
      // — fall back to defaults and let the next save overwrite it.
    }
  }

  /// Pulls nursery policy and the admin's profile from the server, layering
  /// them over the locally cached preferences.
  ///
  /// Theme and text scale are **not** fetched: they are device preferences, not
  /// nursery policy, so an admin's dark-mode choice neither follows them to
  /// another machine nor leaks to other admins.
  Future<void> loadFromServer() async {
    final repository = _repository;
    if (repository == null) return;

    try {
      final settings = await repository.fetchSettings();
      final profile = await repository.fetchProfile();
      await _persist(state.copyWith(
        capacity: settings.capacity,
        currency: settings.currency,
        overtimeHourlyRate: settings.overtimeHourlyRate,
        latePickupGraceMinutes: settings.latePickupGraceMinutes,
        latePickupFine: settings.latePickupRate,
        openingHour: _hourOf(settings.opensAt),
        closingHour: _hourOf(settings.closesAt),
        adminName: profile.fullName,
        adminEmail: profile.email,
      ));
    } on ApiException {
      // Keep the cached settings rather than blanking the app's theme and
      // policy because the network was briefly unavailable. The next save
      // reports its own failure.
    }
  }

  static int _hourOf(String hhmm) =>
      int.tryParse(hhmm.split(':').first) ?? 0;

  Future<void> _persist(AppSettings next) async {
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(next.toJson()));
  }

  Future<void> setThemeMode(ThemeMode mode) => _persist(state.copyWith(themeMode: mode));

  Future<void> setTextScale(double scale) =>
      _persist(state.copyWith(textScale: scale.clamp(0.85, 1.3)));

  /// Returns the failure if the server rejected the change, or null on success.
  /// The screen surfaces it — [AppSettings] is the app's theme state and is not
  /// the right place to carry an error.
  Future<ApiException?> updateProfile({String? name, String? email, String? photoPath}) async {
    // The photo path is a local file reference, so it stays local.
    await _persist(state.copyWith(adminName: name, adminEmail: email, adminPhotoPath: photoPath));

    final repository = _repository;
    if (repository == null || (name == null && email == null)) return null;
    try {
      await repository.updateProfile(fullName: name, email: email);
      return null;
    } on ApiException catch (exception) {
      return exception;
    }
  }

  /// Returns the failure if the server rejected the change, or null on success.
  Future<ApiException?> updateNursery({
    String? name,
    int? capacity,
    String? currency,
    double? overtimeHourlyRate,
    int? latePickupGraceMinutes,
    double? latePickupFine,
    int? openingHour,
    int? closingHour,
  }) async {
    await _persist(state.copyWith(
      nurseryName: name,
      capacity: capacity,
      currency: currency,
      overtimeHourlyRate: overtimeHourlyRate,
      latePickupGraceMinutes: latePickupGraceMinutes,
      latePickupFine: latePickupFine,
      openingHour: openingHour,
      closingHour: closingHour,
    ));

    final repository = _repository;
    if (repository == null) return null;
    try {
      await repository.updateSettings(
        capacity: capacity,
        currency: currency,
        overtimeHourlyRate: overtimeHourlyRate,
        latePickupGraceMinutes: latePickupGraceMinutes,
        latePickupRate: latePickupFine,
        opensAt: openingHour == null ? null : _hhmm(openingHour),
        closesAt: closingHour == null ? null : _hhmm(closingHour),
      );
      return null;
    } on ApiException catch (exception) {
      return exception;
    }
  }

  static String _hhmm(int hour) => '${hour.toString().padLeft(2, '0')}:00';

  /// Wipes persisted preferences back to defaults. The Data section's
  /// "reset" — deliberately does not touch the demo roster, which lives in
  /// memory and is reseeded on restart anyway.
  Future<void> resetToDefaults() async {
    emit(const AppSettings());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
