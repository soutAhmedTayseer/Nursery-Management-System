import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the dark theme against the bug class that broke it once already:
/// a widget that paints its own surface with a light-tuned constant, while
/// the text on top resolves through the palette. The result is invisible in
/// light mode and washed-out grey-on-white in dark.
///
/// This is a source scan rather than a widget test on purpose — the failure
/// is a *rendered* one, so no assertion on a pumped widget catches it. Grep
/// does.
void main() {
  final libDir = Directory('lib');

  /// Palette-internal constants. Anywhere outside `core/theme` these are a
  /// light surface that will not flip.
  final paletteOnlyColors = RegExp(
    r'AppColors\.(surfaceCream|surfaceSand|surfaceSmoke|surfacePage|calendarMuted|creamTint|neutralChip)\b',
  );

  /// Material swatches have no dark counterpart — grey most often (it stands
  /// in for a palette token), but any of them reaching the tree ungated by
  /// the palette is the same bug: fixed in both themes when the surface or
  /// text under it is supposed to flip.
  // (?<!App) so this doesn't match inside `AppColors.brown` etc — "AppColors"
  // ends in "Colors" too, and a plain `Colors\.` with no boundary in front
  // matches right through the "App" prefix.
  final materialSwatch = RegExp(
    r'(?<!App)Colors\.(grey|red|pink|purple|deepPurple|indigo|blue|lightBlue|cyan|teal|'
    r'green|lightGreen|lime|yellow|amber|orange|deepOrange|brown|blueGrey)'
    r'(\.shade\d+)?\b',
  );

  /// `Colors.white` / `Colors.black` in a *surface* slot. The same constant
  /// in a foreground slot is fine and common — white text on a brand-filled
  /// button is white in either theme — so foreground lines are skipped
  /// below rather than matched here.
  final hardcodedSurface = RegExp(
    r'(color|backgroundColor|fillColor|surfaceTintColor|barrierColor):\s*'
    r'Colors\.(white|black)\d*\b',
  );

  /// A foreground slot: the constant paints a glyph, not the box behind it.
  final foregroundSlot = RegExp(r'Icon\(|TextStyle\(|IconData|iconColor|foregroundColor');

  /// Accents tuned for white. As a fill under white text they are correct in
  /// both themes; as label or icon colour on a dark card they fail contrast,
  /// so those uses must go through `palette.brandText` and friends.
  final accentForeground = RegExp(
    r'(TextStyle\(|Icon\(|foregroundColor|iconColor)[^\n]*'
    r'AppColors\.(darkGreen|accentGreen|dangerRed|errorRed|penaltyOrange|amberLabel)\b',
  );

  /// Raw hex outside the theme layer — a colour with no light/dark pair.
  final rawHex = RegExp(r'Color\(0x[0-9a-fA-F]{8}\)');

  /// Whole files that paint onto a brand gradient rather than onto a theme
  /// surface. A gradient is the same gradient in both themes, so white on it
  /// is correct in both.
  const gradientSurfaces = {'lib/features/finance/presentation/widgets/finance_stat_card.dart'};

  /// Lines that legitimately break a rule, each with the reason it is safe.
  ///
  /// [preceding] is the handful of lines above the hit, because a constructor
  /// argument is routinely on a different line from the constructor it
  /// belongs to — a `CircularProgressIndicator(` opened three lines earlier
  /// still governs the `color:` being judged.
  bool isAllowed(String path, String line, List<String> preceding) {
    if (gradientSurfaces.contains(path)) return true;
    if (preceding.any((l) => l.contains('CircularProgressIndicator('))) return true;
    // QR codes are read by a camera, not a human. The quiet zone has to stay
    // white on any theme or phones stop resolving the code.
    if (line.contains('QrImageView')) return true;
    // A spinner only ever appears inside a brand-filled button, on top of
    // the fill, so it is white in both themes.
    if (line.contains('CircularProgressIndicator')) return true;
    // Overlay scrims and watermarks sit on a brand gradient, not a surface.
    if (line.contains('withValues(alpha:') && line.contains('Colors.')) return true;
    if (line.contains('Colors.white24') || line.contains('Colors.white60')) return true;
    // Avatar tints: deliberate pastels that carry dark initials. They read
    // as a colour swatch rather than a surface, and stay legible on a dark
    // card because the text on them is always dark.
    if (line.contains('_kAvatarPalette')) return true;
    // A status badge or button built from a fixed pastel fill
    // (mintTint/peachTint/amberTint) paired with a fixed dark foreground —
    // same pattern as an avatar tint, and for the same reason the pair
    // doesn't flip with the theme.
    if (preceding.any((l) => l.contains('mintTint') || l.contains('peachTint') || l.contains('amberTint'))) {
      return true;
    }
    return false;
  }

  /// [isViolation] receives the few lines above the hit as well, because a
  /// constructor argument routinely sits on a different line from the
  /// constructor that gives it its meaning.
  List<String> scan(
    bool Function(String path, String line, List<String> preceding) isViolation,
  ) {
    final hits = <String>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (path.contains('core/theme/')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        final preceding = lines.sublist(i < 10 ? 0 : i - 10, i);
        if (isAllowed(path, line, preceding)) continue;
        if (isViolation(path, line, preceding)) {
          hits.add('$path:${i + 1}\n    ${line.trim()}');
        }
      }
    }
    return hits;
  }

  void expectClean(List<String> hits, String fix) {
    expect(
      hits,
      isEmpty,
      reason: '${hits.length} hardcoded colour(s) will not flip for dark mode.\n'
          '$fix\n\n${hits.join('\n')}',
    );
  }

  test('no screen paints a surface with a light-only constant', () {
    expectClean(
      scan((_, line, _) => paletteOnlyColors.hasMatch(line)),
      'Use context.palette (page / sand / card / cardMuted / chip / divider).',
    );
  });

  test('no screen uses a Material colour swatch', () {
    expectClean(
      scan((_, line, _) => materialSwatch.hasMatch(line)),
      'Use palette.chip for neutral fills, palette.divider for borders, '
      'palette.textTertiary for de-emphasised text.',
    );
  });

  test('Colors.white and Colors.black never fill a surface', () {
    expectClean(
      // A `TextStyle(` or `Icon(` is often opened a line or two above the
      // `color:` it owns, so the foreground check has to look back too.
      scan(
        (_, line, preceding) =>
            hardcodedSurface.hasMatch(line) &&
            !foregroundSlot.hasMatch(line) &&
            !preceding.any(foregroundSlot.hasMatch),
      ),
      'Use palette.card or palette.sand. Colors.white stays valid only as a '
      'foreground on a brand-coloured fill.',
    );
  });

  test('accent constants are not used as text or icon colour', () {
    expectClean(
      scan((_, line, _) => accentForeground.hasMatch(line)),
      'Use palette.brandText / dangerText / warningText / amberText, which '
      'lift the accent so it stays legible on a dark card.',
    );
  });

  test('no raw hex outside the theme layer', () {
    expectClean(
      scan((_, line, _) => rawHex.hasMatch(line)),
      'Add the colour to AppColors, then expose it through AppPalette if it '
      'differs between themes.',
    );
  });
}
