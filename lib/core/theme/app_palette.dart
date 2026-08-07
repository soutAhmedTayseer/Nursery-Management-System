import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The colours that differ between light and dark.
///
/// Brand and semantic accents (the greens, the danger red, the WhatsApp
/// green, the schedule pastels) stay as constants in [AppColors] — a brand
/// green is the same green in either theme. What actually flips is the
/// surfaces behind content and the text on top of them, so only those live
/// here.
///
/// Read it as `context.palette` (see the extension at the bottom) rather
/// than reaching for `Colors.white` or a raw grey, which is what made the
/// app impossible to render dark.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.page,
    required this.card,
    required this.cardMuted,
    required this.chip,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.inverseText,
    required this.shadow,
    required this.isDark,
  });

  /// Page background behind every screen.
  final Color page;

  /// Raised surface: cards, tables, dialogs, sheets.
  final Color card;

  /// Recessed surface inside a card — table stripes, inset panels.
  final Color cardMuted;

  /// Neutral chip / avatar placeholder background.
  final Color chip;

  final Color divider;

  final Color textPrimary;
  final Color textSecondary;

  /// De-emphasised text: hints, column headers, timestamps.
  final Color textTertiary;

  /// Text drawn on top of a brand-coloured fill.
  final Color inverseText;

  final Color shadow;

  /// Lets a widget branch on theme for the rare case a token can't express
  /// (e.g. swapping an illustration), instead of guessing from luminance.
  final bool isDark;

  static const light = AppPalette(
    page: AppColors.surfaceCream,
    card: Colors.white,
    cardMuted: AppColors.surfaceCream,
    chip: AppColors.neutralChip,
    divider: AppColors.surfaceSmoke,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    inverseText: Colors.white,
    shadow: Color(0x14000000),
    isDark: false,
  );

  /// Warm, low-contrast darks rather than pure black — this is a desktop
  /// admin tool people stare at for a whole shift, and #000 with white text
  /// on large surfaces is fatiguing.
  static const dark = AppPalette(
    page: Color(0xFF15171A),
    card: Color(0xFF1E2125),
    cardMuted: Color(0xFF272B30),
    chip: Color(0xFF33383E),
    divider: Color(0xFF33383E),
    textPrimary: Color(0xFFECEDEE),
    textSecondary: Color(0xFFB4B8BC),
    textTertiary: Color(0xFF8A9096),
    inverseText: Colors.white,
    shadow: Color(0x66000000),
    isDark: true,
  );

  @override
  AppPalette copyWith({
    Color? page,
    Color? card,
    Color? cardMuted,
    Color? chip,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? inverseText,
    Color? shadow,
    bool? isDark,
  }) {
    return AppPalette(
      page: page ?? this.page,
      card: card ?? this.card,
      cardMuted: cardMuted ?? this.cardMuted,
      chip: chip ?? this.chip,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      inverseText: inverseText ?? this.inverseText,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      page: Color.lerp(page, other.page, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardMuted: Color.lerp(cardMuted, other.cardMuted, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      inverseText: Color.lerp(inverseText, other.inverseText, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Falls back to the light palette so a widget rendered outside the app
  /// theme (a bare test pump) still gets sane colours instead of crashing.
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
