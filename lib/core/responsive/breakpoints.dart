import 'package:flutter/widgets.dart';

/// Layout tiers for the admin dashboard.
///
/// Targets are Android tablets, iPad, Windows desktop and desktop web —
/// `compact` covers portrait tablets and narrow browser windows, not phones.
enum Breakpoint { compact, medium, expanded }

const double kMediumBreakpoint = 900;
const double kExpandedBreakpoint = 1200;

Breakpoint breakpointForWidth(double width) {
  if (width >= kExpandedBreakpoint) return Breakpoint.expanded;
  if (width >= kMediumBreakpoint) return Breakpoint.medium;
  return Breakpoint.compact;
}

extension BreakpointContext on BuildContext {
  Breakpoint get breakpoint =>
      breakpointForWidth(MediaQuery.sizeOf(this).width);

  bool get isCompact => breakpoint == Breakpoint.compact;
  bool get isMedium => breakpoint == Breakpoint.medium;
  bool get isExpanded => breakpoint == Breakpoint.expanded;
}
