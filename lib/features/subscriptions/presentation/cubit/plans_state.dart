import '../../data/models/subscription_plan.dart';

class PlansState {
  const PlansState({required this.categories});

  final List<PlanCategory> categories;

  PlansState copyWith({List<PlanCategory>? categories}) =>
      PlansState(categories: categories ?? this.categories);
}
