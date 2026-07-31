import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// A value that differs per [Breakpoint].
///
/// [medium] is optional — when omitted it falls back to [compact], which is
/// the common case (a two-tier value that only changes on wide screens).
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.compact,
    this.medium,
    required this.expanded,
  });

  final T compact;
  final T? medium;
  final T expanded;

  T resolve(BuildContext context) => switch (context.breakpoint) {
        Breakpoint.compact => compact,
        Breakpoint.medium => medium ?? compact,
        Breakpoint.expanded => expanded,
      };
}
