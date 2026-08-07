enum PenaltyFilter { all, withPenalty, withoutPenalty, unpaid, paid }

/// Finance-only figures for one kid. Overtime is derived from the shared
/// attendance ledger rather than stored here — only the manual penalty and
/// any admin override of the computed overtime live in this state.
class FinanceExtras {
  const FinanceExtras({this.overtimeHoursOverride, this.penaltyAmount = 0});

  /// Set when an admin types a different overtime figure than the ledger
  /// computed. Null means "trust the attendance ledger".
  final double? overtimeHoursOverride;

  final double penaltyAmount;
}

class FinanceState {
  const FinanceState({
    this.extrasByKidId = const {},
    this.paidKidIds = const {},
    this.searchQuery = '',
    this.penaltyFilter = PenaltyFilter.all,
  });

  final Map<String, FinanceExtras> extrasByKidId;

  /// Kids whose current invoice the admin has marked settled.
  final Set<String> paidKidIds;

  final String searchQuery;
  final PenaltyFilter penaltyFilter;

  FinanceState copyWith({
    Map<String, FinanceExtras>? extrasByKidId,
    Set<String>? paidKidIds,
    String? searchQuery,
    PenaltyFilter? penaltyFilter,
  }) =>
      FinanceState(
        extrasByKidId: extrasByKidId ?? this.extrasByKidId,
        paidKidIds: paidKidIds ?? this.paidKidIds,
        searchQuery: searchQuery ?? this.searchQuery,
        penaltyFilter: penaltyFilter ?? this.penaltyFilter,
      );
}
