import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/subscription_plan.dart';

class PlansState {
  const PlansState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.currency = 'AED',
  });

  final List<PlanCategory> categories;

  /// True while the catalog is being fetched.
  final bool isLoading;

  /// Set when the last read or write failed. Cleared on the next attempt.
  ///
  /// A write that fails leaves this set **and** rolls the catalog back, so the
  /// screen never shows an edit the server rejected as though it had saved.
  final ApiException? error;

  /// Currency the catalog is priced in, taken from the plans themselves.
  /// Needed when rebuilding a wire [Plan] from an edited line item.
  final String currency;

  PlansState copyWith({
    List<PlanCategory>? categories,
    bool? isLoading,
    ApiException? error,
    String? currency,
    bool clearError = false,
  }) =>
      PlansState(
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        currency: currency ?? this.currency,
      );
}
