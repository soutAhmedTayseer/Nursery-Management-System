import '../../data/models/finance_model.dart';

enum PenaltyFilter { all, withPenalty, withoutPenalty }

enum RevenuePeriod { daily, weekly, monthly }

class FinanceState {
  final List<PaymentRecord> payments;
  final List<PaymentRecord> filteredPayments;
  final String searchQuery;
  final PenaltyFilter penaltyFilter;
  final RevenuePeriod revenuePeriod;

  FinanceState({
    required this.payments,
    required this.filteredPayments,
    this.searchQuery = "",
    this.penaltyFilter = PenaltyFilter.all,
    this.revenuePeriod = RevenuePeriod.weekly,
  });

  FinanceState copyWith({RevenuePeriod? revenuePeriod}) => FinanceState(
        payments: payments,
        filteredPayments: filteredPayments,
        searchQuery: searchQuery,
        penaltyFilter: penaltyFilter,
        revenuePeriod: revenuePeriod ?? this.revenuePeriod,
      );
}
