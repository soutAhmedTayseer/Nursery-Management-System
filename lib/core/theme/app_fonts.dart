/// Font family names bundled under assets/fonts (see pubspec.yaml).
///
/// Matches the Figma "kids-nursery" file: Plus Jakarta Sans for headings,
/// Manrope for body/label text. `AppTheme.light()` sets Manrope as the
/// app-wide default; call sites opt into Jakarta explicitly for headings.
class AppFonts {
  const AppFonts._();

  static const String manrope = 'Manrope';
  static const String jakarta = 'PlusJakartaSans';
}
