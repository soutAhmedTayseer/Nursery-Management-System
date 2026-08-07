import 'package:flutter_bloc/flutter_bloc.dart';
import 'finance_state.dart';

/// Owns finance-only per-kid figures (penalty, overtime overrides, paid
/// status) and the table's search/filter state. The payment list itself is
/// *derived* — built in `derivePaymentRecords` from PlanAssignmentsCubit
/// (who's on what plan) + PlansCubit (plan prices) + the shared attendance
/// ledger (overtime) + this cubit — so it can't drift from the real data.
class FinanceCubit extends Cubit<FinanceState> {
  // Nothing is seeded. Penalties now follow from real attendance via the
  // late-pickup policy, so a flagged row appears because a child was
  // actually collected late — not because one kid was hardcoded.
  FinanceCubit() : super(const FinanceState());

  /// Records an admin's manual figures. [penaltyAmount] overrides the
  /// late-pickup policy for this child — pass 0 to waive the fine, or null
  /// to hand the child back to the policy.
  void setExtras(String kidId, {double? overtimeHours, double? penaltyAmount}) {
    emit(state.copyWith(
      extrasByKidId: {
        ...state.extrasByKidId,
        kidId: FinanceExtras(overtimeHoursOverride: overtimeHours, penaltyOverride: penaltyAmount),
      },
      // Re-invoicing a child reopens their balance.
      paidKidIds: {...state.paidKidIds}..remove(kidId),
    ));
  }

  /// Settles an invoice. One-way on purpose — money received isn't something
  /// an admin should be able to quietly un-record, and every call is written
  /// to the audit log by the caller. Re-invoicing via [setExtras] is the
  /// supported way to reopen a balance, and that leaves its own trail.
  void markPaid(String kidId) {
    if (state.paidKidIds.contains(kidId)) return;
    emit(state.copyWith(paidKidIds: {...state.paidKidIds, kidId}));
  }

  void search(String query) => emit(state.copyWith(searchQuery: query));

  void setPenaltyFilter(PenaltyFilter filter) => emit(state.copyWith(penaltyFilter: filter));
}
