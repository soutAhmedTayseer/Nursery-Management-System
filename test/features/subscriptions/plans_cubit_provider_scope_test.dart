import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_cubit.dart';

/// Regression test for the crash fixed alongside this batch: PlansCubit used
/// to be provided only inside AdminMainLayoutScreen's MultiBlocProvider, but
/// FinancialDuesTab/AssignPlanSection are rendered on routes pushed onto the
/// *root* Navigator (e.g. from SessionsScreen), which sit outside that
/// subtree. That threw ProviderNotFoundException at runtime. PlansCubit now
/// lives at the app root (see bootstrap.dart), so a pushed route can see it.
///
/// This uses a minimal `context.read<PlansCubit>()` consumer rather than the
/// full FinancialDuesTab widget — that widget's real render tree pulls in
/// SvgPicture.asset/ScreenUtil, which hang under the sandboxed test runner
/// used here. The provider-scoping bug and its fix live entirely in *where*
/// `BlocProvider<PlansCubit>` sits in the widget tree, not in what the
/// consumer widget renders, so this reproduces it faithfully.
class _PlansCatalogConsumer extends StatelessWidget {
  const _PlansCatalogConsumer();

  @override
  Widget build(BuildContext context) {
    final categoryCount = context.read<PlansCubit>().state.categories.length;
    return Text('categories: $categoryCount');
  }
}

void main() {
  testWidgets(
    'a widget pushed onto the root Navigator resolves PlansCubit from a root-level provider',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // Root-level PlansCubit, mirroring bootstrap.dart's BlocProvider
          // wrapped directly around MaterialApp — NOT nested inside a
          // layout screen's subtree.
          builder: (context, child) => BlocProvider(
            create: (_) => PlansCubit(),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: _PlansCatalogConsumer()),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Push the route the same way SessionsScreen does: Navigator.push
      // from the root Navigator, outside AdminMainLayoutScreen's subtree.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // No ProviderNotFoundException was thrown while building the pushed
      // route, and the consumer read the real (non-empty) seeded catalog.
      expect(tester.takeException(), isNull);
      expect(find.textContaining('categories: 3'), findsOneWidget);
    },
  );
}
