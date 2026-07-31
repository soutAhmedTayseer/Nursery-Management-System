import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/widgets/confirmation_dialog.dart';

/// Opens the dialog and returns a closure that reads the resolved outcome.
/// The closure must be called only after the confirming/dismissing gesture
/// has been pumped, so the `await ConfirmationDialog.show(...)` inside
/// `onPressed` has had a chance to complete and assign [outcome].
Future<bool? Function()> _showFrom(WidgetTester tester) async {
  bool? outcome;
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    home: Scaffold(
      body: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            outcome = await ConfirmationDialog.show(
              context,
              title: 'Revoke admin',
              message: 'This cannot be undone.',
              confirmLabel: 'Revoke',
            );
          },
          child: const Text('open'),
        );
      }),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => outcome;
}

void main() {
  testWidgets('shows the title and message', (tester) async {
    await _showFrom(tester);
    expect(find.text('Revoke admin'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
  });

  testWidgets('returns true when confirmed', (tester) async {
    final readOutcome = await _showFrom(tester);
    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(readOutcome(), isTrue);
  });

  testWidgets('dismissing without confirming does not resolve true',
      (tester) async {
    final readOutcome = await _showFrom(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(readOutcome(), isFalse);
  });
}
