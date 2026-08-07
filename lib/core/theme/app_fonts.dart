/// Font family names bundled under assets/fonts (see pubspec.yaml).
///
/// Matches the Figma "kids-nursery" file: Plus Jakarta Sans for headings,
/// Manrope for body/label text. `AppTheme` sets Manrope as the app-wide
/// default; call sites opt into Jakarta explicitly for headings.
class AppFonts {
  const AppFonts._();

  static const String manrope = 'Manrope';
  static const String jakarta = 'PlusJakartaSans';

  /// Both bundled families are Latin-only — neither ships Arabic glyphs, so
  /// forcing them on an Arabic locale makes every character fall back
  /// per-glyph and renders unevenly. Returning null hands Arabic to the
  /// platform's own Arabic face (Segoe UI on Windows, Noto Naskh on
  /// Android), which is correct rather than merely passable.
  ///
  /// To bundle a proper Arabic family instead, drop Cairo or Tajawal into
  /// `assets/fonts/`, register it in pubspec.yaml, and return it here.
  static String? bodyFor(String languageCode) => languageCode == 'ar' ? null : manrope;

  static String? headingFor(String languageCode) => languageCode == 'ar' ? null : jakarta;
}
