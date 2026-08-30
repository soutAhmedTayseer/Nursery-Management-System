import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/settings/data/app_settings.dart';
import 'package:nursery_management_system/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('starts on system theme at full text scale', () {
    final state = AppSettingsCubit().state;
    expect(state.themeMode, ThemeMode.system);
    expect(state.textScale, 1.0);
  });

  blocTest<AppSettingsCubit, AppSettings>(
    'theme choice survives a restart',
    build: AppSettingsCubit.new,
    act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
    verify: (_) async {
      // A second cubit reads what the first wrote — this is what stops the
      // app reopening in the wrong theme.
      final reloaded = AppSettingsCubit();
      await reloaded.load();
      expect(reloaded.state.themeMode, ThemeMode.dark);
    },
  );

  blocTest<AppSettingsCubit, AppSettings>(
    'text scale is clamped to a readable band',
    build: AppSettingsCubit.new,
    act: (cubit) async {
      await cubit.setTextScale(5);
      expect(cubit.state.textScale, 1.3);
      await cubit.setTextScale(0.1);
    },
    verify: (cubit) => expect(cubit.state.textScale, 0.85),
  );

  blocTest<AppSettingsCubit, AppSettings>(
    'the local avatar path round-trips through storage',
    build: AppSettingsCubit.new,
    act: (cubit) => cubit.setPhotoPath('/tmp/admin.png'),
    verify: (cubit) async {
      expect(cubit.state.adminPhotoPath, '/tmp/admin.png');
      final reloaded = AppSettingsCubit();
      await reloaded.load();
      expect(reloaded.state.adminPhotoPath, '/tmp/admin.png');
    },
  );

  blocTest<AppSettingsCubit, AppSettings>(
    'nursery figures round-trip through storage',
    build: AppSettingsCubit.new,
    act: (cubit) => cubit.updateNursery(capacity: 80, overtimeHourlyRate: 40, currency: 'USD'),
    verify: (_) async {
      final reloaded = AppSettingsCubit();
      await reloaded.load();
      expect(reloaded.state.capacity, 80);
      expect(reloaded.state.overtimeHourlyRate, 40);
      expect(reloaded.state.currency, 'USD');
    },
  );

  blocTest<AppSettingsCubit, AppSettings>(
    'reset clears persisted settings, not just the in-memory state',
    build: AppSettingsCubit.new,
    act: (cubit) async {
      await cubit.updateNursery(capacity: 99);
      await cubit.resetToDefaults();
    },
    verify: (_) async {
      final reloaded = AppSettingsCubit();
      await reloaded.load();
      expect(reloaded.state.capacity, 50);
    },
  );

  test('a corrupt settings blob falls back to defaults instead of throwing', () async {
    SharedPreferences.setMockInitialValues({'app_settings': 'not-json'});
    final cubit = AppSettingsCubit();
    await cubit.load();
    expect(cubit.state.themeMode, ThemeMode.system);
  });
}
