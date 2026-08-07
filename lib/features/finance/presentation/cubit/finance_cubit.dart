import 'package:flutter_bloc/flutter_bloc.dart';
import 'finance_state.dart';

/// Owns finance-only per-kid figures (penalty, overtime overrides, paid
/// status) and the table's search/filter state. The payment list itself is
/// *derived* — built in `derivePaymentRecords` from PlanAssignmentsCubit
/// (who's on what plan) + PlansCubit (plan prices) + the shared attendance
/// ledger (overtime) + this cubit — so it can't drift from the real data.
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit()
      : super(const FinanceState(
          // One seeded penalty so the demo shows a flagged row out of the
          // box. Overtime is no longer seeded here — it's computed from the
          // child's real attendance.
          extrasByKidId: {'kid-02': FinanceExtras(penaltyAmount: 225)},
        ));

  /// Records a penalty and, optionally, an overtime figure that differs
  /// from what the attendance ledger computed. Pass null [overtimeHours] to
  /// keep trusting the ledger.
  void setExtras(String kidId, {double? overtimeHours, required double penaltyAmount}) {
    emit(state.copyWith(
      extrasByKidId: {
        ...state.extrasByKidId,
        kidId: FinanceExtras(overtimeHoursOverride: overtimeHours, penaltyAmount: penaltyAmount),
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
