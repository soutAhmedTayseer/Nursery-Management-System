enum PenaltyFilter { all, withPenalty, withoutPenalty }

/// Finance-only figures for one kid — overtime/penalty have no equivalent in
/// the subscription catalog, so they're recorded here rather than derived.
class FinanceExtras {
  const FinanceExtras({this.overtimeHours = 0, this.penaltyAmount = 0});

  final double overtimeHours;
  final double penaltyAmount;
}

class FinanceState {
  const FinanceState({
    this.extrasByKidId = const {},
    this.searchQuery = '',
    this.penaltyFilter = PenaltyFilter.all,
  });

  final Map<String, FinanceExtras> extrasByKidId;
  final String searchQuery;
  final PenaltyFilter penaltyFilter;
}
