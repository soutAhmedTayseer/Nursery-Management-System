import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plan_history_cubit.dart';

PlanChangeEntry _entry(String newPlan) => PlanChangeEntry(
      date: DateTime(2026, 5, 1),
      oldPlanLabel: 'Old',
      newPlanLabel: newPlan,
      changedBy: 'Admin',
    );

void main() {
  test('starts empty', () {
    expect(PlanHistoryCubit().state, isEmpty);
  });

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'records a change against the right kid',
    build: PlanHistoryCubit.new,
    act: (cubit) => cubit.record('kid-01', _entry('New Plan')),
    verify: (cubit) {
      expect(cubit.forKid('kid-01').single.newPlanLabel, 'New Plan');
      expect(cubit.forKid('kid-02'), isEmpty);
    },
  );

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'newest change comes first',
    build: PlanHistoryCubit.new,
    act: (cubit) {
      cubit.record('kid-01', _entry('First'));
      cubit.record('kid-01', _entry('Second'));
    },
    verify: (cubit) {
      expect(cubit.forKid('kid-01').map((e) => e.newPlanLabel), ['Second', 'First']);
    },
  );

  blocTest<PlanHistoryCubit, Map<String, List<PlanChangeEntry>>>(
    'one kid\'s history does not disturb another\'s',
    build: PlanHistoryCubit.new,
    act: (cubit) {
      cubit.record('kid-01', _entry('A'));
      cubit.record('kid-02', _entry('B'));
    },
    verify: (cubit) {
      expect(cubit.forKid('kid-01').single.newPlanLabel, 'A');
      expect(cubit.forKid('kid-02').single.newPlanLabel, 'B');
    },
  );
}
