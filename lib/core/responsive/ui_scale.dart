import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// Multiplier for base sizes (apply before `.sp`/`.w`/`.r`) so text, icons,
/// and touch targets read comfortably on a vertical/portrait-ish tablet
/// layout (`compact`/`medium`) without changing the `expanded` (horizontal
/// desktop) layout, which already reads well at 1:1.
///
/// Usage: `fontSize: (14 * context.uiScale).sp`, `size: (18 * context.uiScale).w`.
extension UiScale on BuildContext {
  double get uiScale => switch (breakpoint) {
        Breakpoint.compact => 1.22,
        Breakpoint.medium => 1.22,
        Breakpoint.expanded => 1.0,
      };
}
