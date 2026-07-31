import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/theme/app_colors.dart';
import 'package:nursery_management_system/core/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    test('uses the brand green as its primary seed', () {
      final theme = AppTheme.light();
      expect(theme.colorScheme.primary, isNot(equals(const Color(0xFF6750A4))));
      expect(theme.useMaterial3, isTrue);
    });

    test('paints scaffolds with the app background token', () {
      final theme = AppTheme.light();
      expect(theme.scaffoldBackgroundColor, AppColors.background);
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
}
