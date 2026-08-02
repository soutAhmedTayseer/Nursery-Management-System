import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/subscription_plan.dart';
import 'plans_state.dart';

/// Holds the admin's plan catalog in memory — no backend endpoint for plans
/// yet (see root AGENTS.md contract §"Plans"; wiring GET/POST/PATCH
/// /admin/plans is a follow-up). Seeded from [kInitialPlanCategories].
class PlansCubit extends Cubit<PlansState> {
  PlansCubit({List<PlanCategory>? seed})
      : super(PlansState(categories: seed ?? kInitialPlanCategories));

  void addCategory(PlanCategory category) {
    emit(state.copyWith(categories: [...state.categories, category]));
  }

  void updateCategory(PlanCategory category) {
    emit(state.copyWith(
      categories: [
        for (final c in state.categories)
          if (c.id == category.id) category else c,
      ],
    ));
  }

  void deleteCategory(String categoryId) {
    emit(state.copyWith(
      categories: state.categories.where((c) => c.id != categoryId).toList(),
    ));
  }

  void addLineItem(String categoryId, PlanLineItem item) {
    _updateLineItems(categoryId, (items) => [...items, item]);
  }

  void updateLineItem(String categoryId, PlanLineItem item) {
    _updateLineItems(
      categoryId,
      (items) => [for (final i in items) if (i.id == item.id) item else i],
    );
  }

  void deleteLineItem(String categoryId, String lineItemId) {
    _updateLineItems(
      categoryId,
      (items) => items.where((i) => i.id != lineItemId).toList(),
    );
  }

  void _updateLineItems(
    String categoryId,
    List<PlanLineItem> Function(List<PlanLineItem>) transform,
  ) {
    emit(state.copyWith(
      categories: [
        for (final c in state.categories)
          if (c.id == categoryId)
            c.copyWith(lineItems: transform(c.lineItems))
          else
            c,
      ],
    ));
  }

  (PlanCategory, PlanLineItem)? findLineItem(
    String categoryId,
    String lineItemId,
  ) {
    for (final category in state.categories) {
      if (category.id != categoryId) continue;
      for (final item in category.lineItems) {
        if (item.id == lineItemId) return (category, item);
      }
    }
    return null;
  }
}
