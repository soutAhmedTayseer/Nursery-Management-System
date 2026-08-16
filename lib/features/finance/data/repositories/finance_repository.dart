import 'package:nursery_shared/nursery_shared.dart';

import '../models/finance_model.dart';

/// Month-to-date revenue and total outstanding, as the server computed them.
class FinanceSummary {
  const FinanceSummary({
    required this.revenueMonthToDate,
    required this.totalOutstanding,
    required this.currency,
  });

  final double revenueMonthToDate;
  final double totalOutstanding;
  final String currency;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) => FinanceSummary(
        revenueMonthToDate: (json['revenue_month_to_date'] as num).toDouble(),
        totalOutstanding: (json['total_outstanding'] as num).toDouble(),
        currency: json['currency'] as String? ?? '',
      );
}

/// Finance reads and writes (contract §4 "Finance").
///
/// Nothing here computes money. Every figure — overtime, penalties, totals,
/// outstanding — arrives already calculated, because a rounding rule or a
/// late-pickup policy living in a client means two clients eventually disagree
/// about what a parent owes (contract §2).
/// One point on the revenue chart. Empty buckets are returned as zero so the
/// x-axis stays even.
class RevenueBucket {
  const RevenueBucket({required this.start, required this.revenue});

  final DateTime start;
  final double revenue;

  factory RevenueBucket.fromJson(Map<String, dynamic> json) => RevenueBucket(
        start: DateTime.parse(json['start'] as String),
        revenue: (json['revenue'] as num).toDouble(),
      );
}

enum RevenueGranularity { day, week, month }

abstract class FinanceRepository {
  Future<FinanceSummary> fetchSummary();

  /// Revenue received per bucket between [from] (inclusive) and [to]
  /// (exclusive). The chart needs history the client does not hold — it only
  /// ever has the current page of balances.
  Future<List<RevenueBucket>> fetchRevenue({
    required DateTime from,
    required DateTime to,
    required RevenueGranularity granularity,
  });

  /// One page of per-kid invoices. Filtering and paging are server-side.
  Future<PaginatedResult<PaymentRecord>> fetchBalances({
    int page = 1,
    int pageSize = 20,
    String query = '',
    bool? isPaid,
  });

  /// A manual charge. `note` is required by the contract for `type=manual`.
  Future<void> addManualCharge(
    String kidId, {
    required double amount,
    required String note,
  });

  Future<void> recordPayment(
    String kidId, {
    required double amount,
    required String method,
    String? note,
  });
}
