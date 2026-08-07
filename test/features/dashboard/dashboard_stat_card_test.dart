import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/dashboard/presentation/widgets/dashboard_stat_card.dart';

/// The narrowest a card ever gets on the dashboard (the clamp floor in
/// OverviewScreen) — the width most likely to overflow.
const _narrowest = 240.0;

Widget _host(List<Widget> cards, {double width = _narrowest}) {
  return ScreenUtilInit(
    designSize: const Size(1440, 900),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: kDashboardStatCardHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final card in cards) SizedBox(width: width, height: kDashboardStatCardHeight, child: card),
            ],
          ),
        ),
      ),
    ),
  );
}

DashboardStatCard _card({
  String title = 'CAPACITY',
  String value = '12',
  String? unit,
  String subtitle = 'Total kids present',
  Widget? bottomWidget,
}) {
  return DashboardStatCard(
    title: title,
    value: value,
    unit: unit,
    subtitle: subtitle,
    icon: Icons.tag_faces_rounded,
    themeColor: Colors.green,
    bottomWidget: bottomWidget,
  );
}

void main() {
  testWidgets('renders without overflowing at its narrowest width', (tester) async {
    await tester.pumpWidget(_host([_card()]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long title, huge value and long subtitle still fit', (tester) async {
    await tester.pumpWidget(_host([
      _card(
        title: 'OUTSTANDING PENALTY REVENUE THIS BILLING CYCLE',
        value: '1284500',
        unit: 'AED',
        subtitle: 'Total fees expected but not yet collected this month across every enrolled child.',
      ),
    ]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cards keep an identical size whether or not they have a footer', (tester) async {
    await tester.pumpWidget(_host([
      _card(subtitle: 'Short'),
      _card(
        subtitle: 'A considerably longer subtitle that needs two full lines to render',
        bottomWidget: const SizedBox(height: 5, width: double.infinity),
      ),
    ]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final sizes = tester
        .widgetList<DashboardStatCard>(find.byType(DashboardStatCard))
        .map((card) => tester.getSize(find.byWidget(card)))
        .toList();

    expect(sizes, hasLength(2));
    expect(sizes.first, sizes.last);
  });
}
