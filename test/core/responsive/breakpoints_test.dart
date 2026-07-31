import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/responsive/breakpoints.dart';
import 'package:nursery_management_system/core/responsive/responsive_value.dart';

Widget _at(double width, Widget child) => MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

void main() {
  group('breakpointForWidth', () {
    test('classifies widths at and around each boundary', () {
      expect(breakpointForWidth(320), Breakpoint.compact);
      expect(breakpointForWidth(899.9), Breakpoint.compact);
      expect(breakpointForWidth(900), Breakpoint.medium);
      expect(breakpointForWidth(1199.9), Breakpoint.medium);
      expect(breakpointForWidth(1200), Breakpoint.expanded);
      expect(breakpointForWidth(2560), Breakpoint.expanded);
    });
  });

  group('BuildContext.breakpoint', () {
    testWidgets('reads the breakpoint from MediaQuery width', (tester) async {
      late Breakpoint seen;
      await tester.pumpWidget(_at(1024, Builder(builder: (context) {
        seen = context.breakpoint;
        return const SizedBox();
      })));
      expect(seen, Breakpoint.medium);
    });

    testWidgets('isCompact and isExpanded agree with the breakpoint',
        (tester) async {
      late bool compact;
      late bool expanded;
      await tester.pumpWidget(_at(800, Builder(builder: (context) {
        compact = context.isCompact;
        expanded = context.isExpanded;
        return const SizedBox();
      })));
      expect(compact, isTrue);
      expect(expanded, isFalse);
    });
  });

  group('ResponsiveValue', () {
    testWidgets('resolves the matching tier', (tester) async {
      const value = ResponsiveValue<int>(compact: 1, medium: 2, expanded: 4);
      late int resolved;
      await tester.pumpWidget(_at(1440, Builder(builder: (context) {
        resolved = value.resolve(context);
        return const SizedBox();
      })));
      expect(resolved, 4);
    });

    testWidgets('falls back to compact when medium is omitted',
        (tester) async {
      const value = ResponsiveValue<int>(compact: 1, expanded: 4);
      late int resolved;
      await tester.pumpWidget(_at(1000, Builder(builder: (context) {
        resolved = value.resolve(context);
        return const SizedBox();
      })));
      expect(resolved, 1);
    });
  });
}
