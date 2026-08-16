import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/plan_catalog.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/repositories/plans_repository.dart';
import 'plans_state.dart';

/// The admin's plan catalog, backed by `/plans` and `/admin/plans`.
///
/// Writes are optimistic — the edit shows immediately, then the request goes
/// out. If it fails the catalog is rolled back to what the server last
/// confirmed and the error is surfaced, so a rejected edit is never left on
/// screen looking saved.
class PlansCubit extends Cubit<PlansState> {
  PlansCubit(this._repository) : super(const PlansState());

  final PlansRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final plans = await _repository.fetchPlans();
      emit(state.copyWith(
        categories: PlanCatalog.group(plans),
        currency: plans.isEmpty ? state.currency : plans.first.currency,
        isLoading: false,
        clearError: true,
      ));
    } on ApiException catch (exception) {
      emit(state.copyWith(isLoading: false, error: exception));
    }
  }

  /// Creates every line item in a new category, or adds the ones missing from
  /// an existing one. Categories are not a server resource — a category exists
  /// because plans name it (contract §2).
  Future<void> addCategory(PlanCategory category) => _write(
        optimistic: [...state.categories, category],
        request: () async {
          for (final item in category.lineItems) {
            await _repository.createPlan(_toPlan(item, category));
          }
        },
      );

  Future<void> updateCategory(PlanCategory category) => _write(
        optimistic: [
          for (final c in state.categories)
            if (c.id == category.id) category else c,
        ],
        request: () async {
          for (final item in category.lineItems) {
            await _repository.updatePlan(_toPlan(item, category));
          }
        },
      );

  /// Deactivates every plan in the category — plans are referenced by past
  /// subscriptions and history, so they are never hard-deleted.
  Future<void> deleteCategory(String categoryId) {
    final category = _categoryById(categoryId);
    if (category == null) return Future.value();

    return _write(
      optimistic: state.categories.where((c) => c.id != categoryId).toList(),
      request: () async {
        for (final item in category.lineItems) {
          await _repository.deactivatePlan(item.id);
        }
      },
    );
  }

  Future<void> addLineItem(String categoryId, PlanLineItem item) {
    final category = _categoryById(categoryId);
    if (category == null) return Future.value();

    return _write(
      optimistic: _mapLineItems(categoryId, (items) => [...items, item]),
      request: () => _repository.createPlan(_toPlan(item, category)),
    );
  }

  Future<void> updateLineItem(String categoryId, PlanLineItem item) {
    final category = _categoryById(categoryId);
    if (category == null) return Future.value();

    return _write(
      optimistic: _mapLineItems(
        categoryId,
        (items) => [for (final i in items) if (i.id == item.id) item else i],
      ),
      request: () => _repository.updatePlan(_toPlan(item, category)),
    );
  }

  Future<void> deleteLineItem(String categoryId, String lineItemId) => _write(
        optimistic: _mapLineItems(
          categoryId,
          (items) => items.where((i) => i.id != lineItemId).toList(),
        ),
        request: () => _repository.deactivatePlan(lineItemId),
      );

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

  /// Shows [optimistic] straight away, then runs [request]. On failure the
  /// catalog snaps back to what it was and the exception is surfaced.
  Future<void> _write({
    required List<PlanCategory> optimistic,
    required Future<void> Function() request,
  }) async {
    final rollback = state.categories;
    emit(state.copyWith(categories: optimistic, clearError: true));

    try {
      await request();
      // Re-read so server-assigned ids replace any placeholder the UI minted.
      await load();
    } on ApiException catch (exception) {
      emit(state.copyWith(categories: rollback, error: exception));
    }
  }

  List<PlanCategory> _mapLineItems(
    String categoryId,
    List<PlanLineItem> Function(List<PlanLineItem>) transform,
  ) =>
      [
        for (final c in state.categories)
          if (c.id == categoryId) c.copyWith(lineItems: transform(c.lineItems)) else c,
      ];

  PlanCategory? _categoryById(String id) {
    for (final category in state.categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Plan _toPlan(PlanLineItem item, PlanCategory category) => PlanCatalog.toPlan(
        item,
        category: category.name,
        currency: state.currency,
        isFeatured: category.isFeatured,
      );
}
