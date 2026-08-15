import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_management_system/features/subscriptions/data/repositories/plans_repository.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_cubit.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_state.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockPlansRepository extends Mock implements PlansRepository {}

Plan _plan(String id, {String category = 'Monthly Packages', String name = 'One Hour'}) => Plan(
      id: id,
      name: name,
      category: category,
      hoursIncluded: 1,
      hoursPerDay: 1,
      daysPerCycle: 1,
      price: 35,
      currency: 'AED',
      badgeText: null,
      isFeatured: false,
      active: true,
    );

const _boom = ApiException(
  code: 'SERVER_ERROR',
  message: 'boom',
  statusCode: 500,
);

void main() {
  late _MockPlansRepository repository;

  setUp(() {
    repository = _MockPlansRepository();
    registerFallbackValue(_plan('fallback'));
  });

  group('load', () {
    blocTest<PlansCubit, PlansState>(
      'groups the flat plan list into categories',
      setUp: () {
        when(repository.fetchPlans).thenAnswer((_) async => [
              _plan('p1', name: 'One Hour'),
              _plan('p2', name: 'Two Hours'),
              _plan('p3', category: 'Daily Subscription', name: 'Full Day'),
            ]);
      },
      build: () => PlansCubit(repository),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.categories, hasLength(2));
        expect(cubit.state.categories.first.name, 'Monthly Packages');
        expect(cubit.state.categories.first.lineItems, hasLength(2));
        // Numeric price becomes the display string the screen renders.
        expect(cubit.state.categories.first.lineItems.first.price, '35 AED');
        expect(cubit.state.error, isNull);
      },
    );

    blocTest<PlansCubit, PlansState>(
      'surfaces a failed read instead of showing an empty catalog',
      setUp: () => when(repository.fetchPlans).thenThrow(_boom),
      build: () => PlansCubit(repository),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.error, _boom);
      },
    );
  });

  group('writes', () {
    const item = PlanLineItem(id: 'li2', label: 'Two Hours', price: '60 AED');

    blocTest<PlansCubit, PlansState>(
      'addLineItem creates the plan and re-reads the catalog',
      setUp: () {
        when(repository.fetchPlans).thenAnswer((_) async => [_plan('p1')]);
        when(() => repository.createPlan(any())).thenAnswer((i) async => i.positionalArguments.first as Plan);
      },
      build: () => PlansCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.addLineItem('monthly_packages', item);
      },
      verify: (_) {
        verify(() => repository.createPlan(any())).called(1);
        // Re-read so server-assigned ids replace anything the UI minted.
        verify(repository.fetchPlans).called(2);
      },
    );

    blocTest<PlansCubit, PlansState>(
      'a rejected write rolls the catalog back and reports the error',
      setUp: () {
        when(repository.fetchPlans).thenAnswer((_) async => [_plan('p1')]);
        when(() => repository.createPlan(any())).thenThrow(_boom);
      },
      build: () => PlansCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.addLineItem('monthly_packages', item);
      },
      verify: (cubit) {
        // The point: a rejected edit must not be left on screen looking saved.
        expect(cubit.state.categories.single.lineItems, hasLength(1));
        expect(cubit.state.categories.single.lineItems.single.id, 'p1');
        expect(cubit.state.error, _boom);
      },
    );

    blocTest<PlansCubit, PlansState>(
      'deleteLineItem deactivates rather than deleting',
      setUp: () {
        when(repository.fetchPlans).thenAnswer((_) async => [_plan('p1')]);
        when(() => repository.deactivatePlan('p1')).thenAnswer((_) async => _plan('p1'));
      },
      build: () => PlansCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.deleteLineItem('monthly_packages', 'p1');
      },
      verify: (_) => verify(() => repository.deactivatePlan('p1')).called(1),
    );

    blocTest<PlansCubit, PlansState>(
      'deleteCategory deactivates every plan under it',
      setUp: () {
        when(repository.fetchPlans).thenAnswer((_) async => [
              _plan('p1', name: 'One Hour'),
              _plan('p2', name: 'Two Hours'),
            ]);
        when(() => repository.deactivatePlan(any())).thenAnswer((_) async => _plan('p1'));
      },
      build: () => PlansCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.deleteCategory('monthly_packages');
      },
      verify: (_) {
        verify(() => repository.deactivatePlan('p1')).called(1);
        verify(() => repository.deactivatePlan('p2')).called(1);
      },
    );
  });

  test('findLineItem locates an item by category and id', () async {
    when(repository.fetchPlans).thenAnswer((_) async => [_plan('p1')]);
    final cubit = PlansCubit(repository);
    await cubit.load();

    expect(cubit.findLineItem('monthly_packages', 'p1'), isNotNull);
    expect(cubit.findLineItem('monthly_packages', 'nope'), isNull);
  });
}
