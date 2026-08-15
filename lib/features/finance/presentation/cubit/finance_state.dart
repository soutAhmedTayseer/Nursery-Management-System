import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/finance_model.dart';
import '../../data/repositories/finance_repository.dart';

enum PenaltyFilter { all, withPenalty, withoutPenalty, unpaid, paid }

class FinanceState {
  const FinanceState({
    this.records = const [],
    this.summary,
    this.revenue = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.penaltyFilter = PenaltyFilter.all,
  });

  /// The current page of per-kid invoices, exactly as the server computed them.
  /// Nothing here is derived client-side (contract §2).
  final List<PaymentRecord> records;

  final FinanceSummary? summary;

  /// Revenue series backing the chart, oldest bucket first.
  final List<RevenueBucket> revenue;

  final bool isLoading;

  /// Set when a read or a write failed.
  ///
  /// This screen records payments and charges, so a failure that is not shown
  /// is money the admin believes was recorded and was not.
  final ApiException? error;

  final String searchQuery;
  final PenaltyFilter penaltyFilter;

  /// Rows after the penalty/paid filter, which is applied here because it is a
  /// view concern over the page already fetched. The search itself is
  /// server-side, since it selects which rows the page contains at all.
  List<PaymentRecord> get visibleRecords => switch (penaltyFilter) {
        PenaltyFilter.all => records,
        PenaltyFilter.withPenalty =>
          records.where((r) => r.penaltyAmount > 0).toList(),
        PenaltyFilter.withoutPenalty =>
          records.where((r) => r.penaltyAmount == 0).toList(),
        PenaltyFilter.paid => records.where((r) => r.isPaid).toList(),
        PenaltyFilter.unpaid => records.where((r) => !r.isPaid).toList(),
      };

  FinanceState copyWith({
    List<PaymentRecord>? records,
    FinanceSummary? summary,
    List<RevenueBucket>? revenue,
    bool? isLoading,
    ApiException? error,
    String? searchQuery,
    PenaltyFilter? penaltyFilter,
    bool clearError = false,
  }) =>
      FinanceState(
        records: records ?? this.records,
        summary: summary ?? this.summary,
        revenue: revenue ?? this.revenue,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        searchQuery: searchQuery ?? this.searchQuery,
        penaltyFilter: penaltyFilter ?? this.penaltyFilter,
      );
}
