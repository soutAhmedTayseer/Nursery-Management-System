import 'package:flutter/widgets.dart';

import '../responsive/breakpoints.dart';

/// Layout dimensions, selected per [Breakpoint].
///
/// Typography still goes through `flutter_screenutil` (`.sp`). Layout does
/// not: a desktop UI reflows, it does not zoom, and linearly scaling padding
/// from a 1440px reference is what makes these screens look squeezed on a
/// tablet. See root AGENTS.md §6.
class AppSpacing {
  const AppSpacing._({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.pagePadding,
    required this.gutter,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  /// Outer padding of a screen's scrollable body.
  final double pagePadding;

  /// Gap between sibling cards in a grid or row.
  final double gutter;

  // Radii and icon sizes are brand constants, not layout dimensions — they do
  // not vary by breakpoint. Static so context-free code (AppTheme) can use
  // them: nothing outside this file may write a bare pixel literal.
  // Values match the radii already used across the existing screens — the
  // visual design does not change in this phase, only where the numbers live.
  static const double radiusSm = 8;
  static const double radiusMd = 12; // text fields, buttons
  static const double radiusLg = 16; // small cards, dialogs
  static const double radiusXl = 32; // large panels

  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 40;
  static const double hairline = 1;

  static const AppSpacing _compact = AppSpacing._(
    xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32,
    pagePadding: 16, gutter: 12,
  );

  static const AppSpacing _medium = AppSpacing._(
    xs: 4, sm: 8, md: 16, lg: 20, xl: 28, xxl: 40,
    pagePadding: 24, gutter: 16,
  );

  static const AppSpacing _expanded = AppSpacing._(
    xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48,
    pagePadding: 32, gutter: 24,
  );

  static AppSpacing of(BuildContext context) => switch (context.breakpoint) {
        Breakpoint.compact => _compact,
        Breakpoint.medium => _medium,
        Breakpoint.expanded => _expanded,
      };
}
