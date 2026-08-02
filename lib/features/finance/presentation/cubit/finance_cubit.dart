import 'package:flutter_bloc/flutter_bloc.dart';
import 'finance_state.dart';

/// Owns finance-only per-kid figures (overtime/penalty) and the table's
/// search/filter state. The payment list itself is *derived* — built in
/// FinanceScreen from PlanAssignmentsCubit (who's on what plan) + PlansCubit
/// (plan prices) + this cubit's extras — so it can't drift from the real
/// subscription catalog.
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit()
      : super(const FinanceState(
          // Matches PlanAssignmentsCubit's seed-2 (James Khan/Amara Khan) so
          // the demo data shows a penalty row out of the box.
          extrasByKidId: {'seed-2': FinanceExtras(overtimeHours: 4.5, penaltyAmount: 225)},
        ));

  void setExtras(String kidId, {required double overtimeHours, required double penaltyAmount}) {
    emit(FinanceState(
      extrasByKidId: {...state.extrasByKidId, kidId: FinanceExtras(overtimeHours: overtimeHours, penaltyAmount: penaltyAmount)},
      searchQuery: state.searchQuery,
      penaltyFilter: state.penaltyFilter,
    ));
  }

  void search(String query) {
    emit(FinanceState(extrasByKidId: state.extrasByKidId, searchQuery: query, penaltyFilter: state.penaltyFilter));
  }

  void setPenaltyFilter(PenaltyFilter filter) {
    emit(FinanceState(extrasByKidId: state.extrasByKidId, searchQuery: state.searchQuery, penaltyFilter: filter));
  }
}
