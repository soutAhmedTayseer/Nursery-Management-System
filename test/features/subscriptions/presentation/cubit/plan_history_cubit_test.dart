import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_management_system/features/subscriptions/data/repositories/plans_repository.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plan_history_cubit.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockPlansRepository extends Mock implements PlansRepository {}

PlanChange _change(String id, {String? from, required String to}) => PlanChange(
      id: id,
      kidId: 'kid-1',
      oldPlanName: from,
      newPlanName: to,
      changedBy: 'admin',
      changedAt: DateTime(2026, 8, 1),
    );

void main() {
  late _MockPlansRepository repository;

  setUp(() => repository = _MockPlansRepository());

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'starts empty',
    build: () => PlanHistoryCubit(repository),
    verify: (cubit) => expect(cubit.state, isEmpty),
  );

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'loads a kid history, keeping the server order',
    setUp: () {
      when(() => repository.fetchPlanHistory('kid-1')).thenAnswer((_) async => [
            _change('c2', from: 'Weekly', to: 'Monthly'),
            _change('c1', to: 'Weekly'),
          ]);
    },
    build: () => PlanHistoryCubit(repository),
    act: (cubit) => cubit.loadForKid('kid-1'),
    verify: (cubit) {
      final entries = cubit.forKid('kid-1');
      expect(entries.map((e) => e.newPlanLabel), ['Monthly', 'Weekly']);
      // A first assignment has no previous plan.
      expect(entries.last.oldPlanLabel, '');
    },
  );

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'keeps histories for different kids apart',
    setUp: () {
      when(() => repository.fetchPlanHistory('kid-1'))
          .thenAnswer((_) async => [_change('c1', to: 'Monthly')]);
      when(() => repository.fetchPlanHistory('kid-2'))
          .thenAnswer((_) async => [_change('c2', to: 'Daily')]);
    },
    build: () => PlanHistoryCubit(repository),
    act: (cubit) async {
      await cubit.loadForKid('kid-1');
      await cubit.loadForKid('kid-2');
    },
    verify: (cubit) {
      expect(cubit.forKid('kid-1').single.newPlanLabel, 'Monthly');
      expect(cubit.forKid('kid-2').single.newPlanLabel, 'Daily');
    },
  );

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'a failed history read leaves the last known list rather than blanking it',
    setUp: () {
      var calls = 0;
      when(() => repository.fetchPlanHistory('kid-1')).thenAnswer((_) async {
        if (calls++ == 0) return [_change('c1', to: 'Monthly')];
        throw const ApiException(
          code: 'SERVER_ERROR',
          message: 'boom',
          statusCode: 500,
        );
      });
    },
    build: () => PlanHistoryCubit(repository),
    act: (cubit) async {
      await cubit.loadForKid('kid-1');
      await cubit.loadForKid('kid-1');
    },
    verify: (cubit) {
      // History is a supporting panel; a failed refresh must not wipe it.
      expect(cubit.forKid('kid-1').single.newPlanLabel, 'Monthly');
    },
  );
}
