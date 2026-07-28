import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('shows label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(PrimaryButton(
      label: 'Submit',
      onPressed: () => tapped = true,
    )));

    expect(find.text('Submit'), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner instead of the label when isLoading', (tester) async {
    await tester.pumpWidget(wrap(PrimaryButton(
      label: 'Submit',
      onPressed: () {},
      isLoading: true,
    )));

    expect(find.text('Submit'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
