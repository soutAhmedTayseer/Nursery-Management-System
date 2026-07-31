import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/theme/app_spacing.dart';

Future<AppSpacing> _spacingAt(WidgetTester tester, double width) async {
  late AppSpacing spacing;
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(builder: (context) {
        spacing = AppSpacing.of(context);
        return const SizedBox();
      }),
    ),
  ));
  return spacing;
}

void main() {
  testWidgets('page padding grows with the breakpoint', (tester) async {
    final compact = await _spacingAt(tester, 800);
    final expanded = await _spacingAt(tester, 1440);
    expect(compact.pagePadding, lessThan(expanded.pagePadding));
  });

  testWidgets('the scale is monotonic within a tier', (tester) async {
    final spacing = await _spacingAt(tester, 1440);
    expect(spacing.xs, lessThan(spacing.sm));
    expect(spacing.sm, lessThan(spacing.md));
    expect(spacing.md, lessThan(spacing.lg));
    expect(spacing.lg, lessThan(spacing.xl));
    expect(spacing.xl, lessThan(spacing.xxl));
  });

  test('radii and icon sizes are context-free constants', () {
    // AppTheme has no BuildContext, so these must not require one.
    expect(AppSpacing.radiusSm, lessThan(AppSpacing.radiusMd));
    expect(AppSpacing.radiusMd, lessThan(AppSpacing.radiusLg));
    expect(AppSpacing.radiusLg, lessThan(AppSpacing.radiusXl));
    expect(AppSpacing.iconSm, lessThan(AppSpacing.iconLg));
    expect(AppSpacing.hairline, 1);
  });
}
