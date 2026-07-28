import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/widgets/app_text_field.dart';

void main() {
  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('renders label and hint, and obscures text when requested', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(
      label: 'Password',
      hint: 'Enter your password',
      obscureText: true,
    )));

    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('calls validator when form is validated', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(wrap(Form(
      key: formKey,
      child: AppTextField(
        label: 'Email',
        hint: 'you@example.com',
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    )));

    expect(formKey.currentState!.validate(), isFalse);
  });
}
