import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_settings.dart';

/// Owns every admin-configurable preference and writes each change to disk.
///
/// Settings are the one thing that must outlive a restart even in the demo
/// build — an admin who picks dark mode and finds it light again next
/// launch will assume the toggle is broken.
class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit() : super(const AppSettings());

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

  Future<void> _persist(AppSettings next) async {
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(next.toJson()));
  }

  Future<void> setThemeMode(ThemeMode mode) => _persist(state.copyWith(themeMode: mode));

  Future<void> setTextScale(double scale) =>
      _persist(state.copyWith(textScale: scale.clamp(0.85, 1.3)));

  Future<void> updateProfile({String? name, String? email, String? photoPath}) =>
      _persist(state.copyWith(adminName: name, adminEmail: email, adminPhotoPath: photoPath));

  Future<void> updateNursery({
    String? name,
    int? capacity,
    String? currency,
    double? overtimeHourlyRate,
    int? openingHour,
    int? closingHour,
  }) {
    return _persist(state.copyWith(
      nurseryName: name,
      capacity: capacity,
      currency: currency,
      overtimeHourlyRate: overtimeHourlyRate,
      openingHour: openingHour,
      closingHour: closingHour,
    ));
  }

  /// Wipes persisted preferences back to defaults. The Data section's
  /// "reset" — deliberately does not touch the demo roster, which lives in
  /// memory and is reseeded on restart anyway.
  Future<void> resetToDefaults() async {
    emit(const AppSettings());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
