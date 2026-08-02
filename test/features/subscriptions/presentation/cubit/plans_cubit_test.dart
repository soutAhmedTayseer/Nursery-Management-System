import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_cubit.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_state.dart';

const _category = PlanCategory(
  id: 'cat1',
  name: 'Test Category',
  icon: Icons.star,
  themeColor: Colors.green,
  lineItems: [PlanLineItem(id: 'li1', label: 'One Hour', price: '35 AED')],
);

void main() {
  test('starts seeded with kInitialPlanCategories', () {
    expect(PlansCubit().state.categories, kInitialPlanCategories);
  });

  blocTest<PlansCubit, PlansState>(
    'addCategory appends a new category',
    build: PlansCubit.new,
    act: (cubit) => cubit.addCategory(_category),
    verify: (cubit) => expect(cubit.state.categories, contains(_category)),
  );

  blocTest<PlansCubit, PlansState>(
    'updateCategory replaces the category with matching id',
    build: () => PlansCubit(seed: [_category]),
    act: (cubit) => cubit.updateCategory(_category.copyWith(name: 'Renamed')),
    verify: (cubit) => expect(cubit.state.categories.single.name, 'Renamed'),
  );

  blocTest<PlansCubit, PlansState>(
    'deleteCategory removes the category with matching id',
    build: () => PlansCubit(seed: [_category]),
    act: (cubit) => cubit.deleteCategory('cat1'),
    verify: (cubit) => expect(cubit.state.categories, isEmpty),
  );

  blocTest<PlansCubit, PlansState>(
    'addLineItem appends to the named category',
    build: () => PlansCubit(seed: [_category]),
    act: (cubit) => cubit.addLineItem(
      'cat1',
      const PlanLineItem(id: 'li2', label: 'Two Hours', price: '60 AED'),
    ),
    verify: (cubit) =>
        expect(cubit.state.categories.single.lineItems, hasLength(2)),
  );

  blocTest<PlansCubit, PlansState>(
    'updateLineItem replaces the line item with matching id',
    build: () => PlansCubit(seed: [_category]),
    act: (cubit) => cubit.updateLineItem(
      'cat1',
      const PlanLineItem(id: 'li1', label: 'One Hour', price: '40 AED'),
    ),
    verify: (cubit) =>
        expect(cubit.state.categories.single.lineItems.single.price, '40 AED'),
  );

  blocTest<PlansCubit, PlansState>(
    'deleteLineItem removes the line item with matching id',
    build: () => PlansCubit(seed: [_category]),
    act: (cubit) => cubit.deleteLineItem('cat1', 'li1'),
    verify: (cubit) =>
        expect(cubit.state.categories.single.lineItems, isEmpty),
  );

  test('findLineItem returns the category and line item for matching ids', () {
    final cubit = PlansCubit(seed: [_category]);
    final result = cubit.findLineItem('cat1', 'li1');
    expect(result?.$1.id, 'cat1');
    expect(result?.$2.id, 'li1');
  });

  test('findLineItem returns null for unknown ids', () {
    final cubit = PlansCubit(seed: [_category]);
    expect(cubit.findLineItem('nope', 'li1'), isNull);
  });
}
