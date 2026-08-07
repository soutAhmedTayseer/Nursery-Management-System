import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_palette.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({String languageCode = 'en'}) =>
      _build(AppPalette.light, Brightness.light, languageCode);

  static ThemeData dark({String languageCode = 'en'}) =>
      _build(AppPalette.dark, Brightness.dark, languageCode);

  /// Both themes come off the same builder so a token added for light can't
  /// be silently forgotten in dark — only the [palette] differs.
  static ThemeData _build(AppPalette palette, Brightness brightness, String languageCode) {
    final isDark = brightness == Brightness.dark;
    // The brand green is tuned for white backgrounds; on a dark surface it
    // reads muddy and fails contrast, so lift it toward the gradient's
    // light end rather than inventing a second brand colour.
    final primary = isDark ? AppColors.leafGreen : AppColors.darkGreen;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkGreen,
      brightness: brightness,
      primary: primary,
      secondary: AppColors.gold,
      error: isDark ? AppColors.peachTint : AppColors.errorRed,
      surface: palette.card,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.page,
      canvasColor: palette.page,
      dialogTheme: DialogThemeData(backgroundColor: palette.card),
      popupMenuTheme: PopupMenuThemeData(color: palette.card),
      // Figma's "kids-nursery" file uses Manrope for body text and Plus
      // Jakarta Sans for headings. Neither covers Arabic, so an Arabic
      // locale falls through to the platform font — see AppFonts.
      fontFamily: AppFonts.bodyFor(languageCode),
      extensions: [palette],
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.cardMuted,
        hintStyle: TextStyle(color: palette.textTertiary),
        labelStyle: TextStyle(color: palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? AppColors.textPrimary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
      ),
      iconTheme: IconThemeData(color: palette.textSecondary),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: AppFonts.headingFor(languageCode),
          fontWeight: FontWeight.w900,
          color: palette.textPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
        bodyMedium: TextStyle(color: palette.textSecondary),
        labelSmall: TextStyle(color: palette.textTertiary),
      ),
    );
  }
}
