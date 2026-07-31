import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/widgets/async_state_view.dart';
import 'package:nursery_management_system/core/widgets/list_skeleton.dart';
import 'package:nursery_shared/nursery_shared.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(body: child),
  ));
}

void main() {
  testWidgets('shows the skeleton while loading', (tester) async {
    await _pump(
      tester,
      AsyncStateView(
        isLoading: true,
        error: null,
        isEmpty: false,
        onRetry: () {},
        emptyMessage: 'nothing',
        builder: (_) => const Text('DATA'),
      ),
    );
    expect(find.byType(ListSkeleton), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('shows the empty message when there is no data',
      (tester) async {
    await _pump(
      tester,
      AsyncStateView(
        isLoading: false,
        error: null,
        isEmpty: true,
        onRetry: () {},
        emptyMessage: 'nothing here',
        builder: (_) => const Text('DATA'),
      ),
    );
    expect(find.text('nothing here'), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('shows a retry button on error and fires the callback',
      (tester) async {
    var retried = false;
    await _pump(
      tester,
      AsyncStateView(
        isLoading: false,
        error: const ApiException(
          code: 'NETWORK_ERROR',
          message: 'raw dio text that must never be shown',
          statusCode: null,
        ),
        isEmpty: true,
        onRetry: () => retried = true,
        emptyMessage: 'nothing',
        builder: (_) => const Text('DATA'),
      ),
    );

    expect(find.text('raw dio text that must never be shown'), findsNothing);
    await tester.tap(find.byType(TextButton));
    expect(retried, isTrue);
  });

  testWidgets('error wins over loading', (tester) async {
    await _pump(
      tester,
      AsyncStateView(
        isLoading: true,
        error: const ApiException(
          code: 'NETWORK_ERROR',
          message: 'x',
          statusCode: null,
        ),
        isEmpty: true,
        onRetry: () {},
        emptyMessage: 'nothing',
        builder: (_) => const Text('DATA'),
      ),
    );
    expect(find.byType(ListSkeleton), findsNothing);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('renders the builder when data is present', (tester) async {
    await _pump(
      tester,
      AsyncStateView(
        isLoading: false,
        error: null,
        isEmpty: false,
        onRetry: () {},
        emptyMessage: 'nothing',
        builder: (_) => const Text('DATA'),
      ),
    );
    expect(find.text('DATA'), findsOneWidget);
  });
}
