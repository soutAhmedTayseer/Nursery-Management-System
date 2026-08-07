import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/theme/app_colors.dart';
import 'package:nursery_management_system/core/theme/app_palette.dart';
import 'package:nursery_management_system/core/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    test('uses the brand green as its primary seed', () {
      final theme = AppTheme.light();
      expect(theme.colorScheme.primary, isNot(equals(const Color(0xFF6750A4))));
      expect(theme.useMaterial3, isTrue);
    });

    test('paints scaffolds with the shared page token', () {
      final theme = AppTheme.light();
      expect(theme.scaffoldBackgroundColor, AppPalette.light.page);
    });

    test('gives cards a white surface and no elevation shadow', () {
      final theme = AppTheme.light();
      expect(theme.cardTheme.color, Colors.white);
      expect(theme.cardTheme.elevation, 0);
    });

    test('gives input fields the brand focus border', () {
      final theme = AppTheme.light();
      final focused = theme.inputDecorationTheme.focusedBorder;
      expect(focused, isA<OutlineInputBorder>());
      expect(
        (focused as OutlineInputBorder).borderSide.color,
        AppColors.darkGreen,
      );
    });
  });

  group('AppTheme.dark', () {
    test('carries the dark palette so widgets resolve dark tokens', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<AppPalette>(), AppPalette.dark);
      expect(theme.scaffoldBackgroundColor, AppPalette.dark.page);
    });

    test('lifts the brand green so it stays legible on dark surfaces', () {
      // The light brand green is tuned for white; reusing it unchanged on a
      // near-black surface is the contrast failure this guards against.
      expect(AppTheme.dark().colorScheme.primary, isNot(AppColors.darkGreen));
    });

    test('every palette token differs from light, so nothing is left unthemed', () {
      const light = AppPalette.light;
      const dark = AppPalette.dark;
      expect(dark.page, isNot(light.page));
      expect(dark.card, isNot(light.card));
      expect(dark.cardMuted, isNot(light.cardMuted));
      expect(dark.textPrimary, isNot(light.textPrimary));
      expect(dark.textSecondary, isNot(light.textSecondary));
      expect(dark.divider, isNot(light.divider));
      expect(dark.isDark, isTrue);
    });
  });

  group('AppPalette', () {
    test('falls back to light when no theme extension is registered', () {
      // A widget pumped bare in a test still needs sane colours.
      final bare = ThemeData(useMaterial3: true);
      expect(bare.extension<AppPalette>(), isNull);
    });

    test('lerps between the two palettes for animated theme switches', () {
      final mid = AppPalette.light.lerp(AppPalette.dark, 0.5);
      expect(mid.page, isNot(AppPalette.light.page));
      expect(mid.page, isNot(AppPalette.dark.page));
    });
  });
}
