import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/widgets/adaptive_collection.dart';

Future<void> _pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AdaptiveCollection<String>(
        items: const ['alpha', 'beta'],
        columns: [
          AdaptiveColumn<String>(label: 'Name', cell: (v) => Text('cell-$v')),
        ],
        cardBuilder: (context, value) => Text('card-$value'),
      ),
    ),
  ));
}

void main() {
  testWidgets('renders a table at the expanded breakpoint', (tester) async {
    await _pumpAt(tester, 1440);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('cell-alpha'), findsOneWidget);
    expect(find.text('card-alpha'), findsNothing);
  });

  testWidgets('renders cards at the medium breakpoint', (tester) async {
    await _pumpAt(tester, 1024);
    expect(find.text('card-alpha'), findsOneWidget);
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('renders cards at the compact breakpoint', (tester) async {
    await _pumpAt(tester, 700);
    expect(find.text('card-beta'), findsOneWidget);
    expect(find.text('cell-beta'), findsNothing);
  });
}
