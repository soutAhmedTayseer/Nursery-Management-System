import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/plan_assignment.dart';
import '../../data/repositories/plans_repository.dart';
import 'plan_assignments_state.dart';

/// Which kid is on which plan — app-root state (see bootstrap.dart) so it
/// survives navigation.
///
/// Assignment is separate from payment (contract §4): [assign] puts a child on
/// a plan and moves no money. A child can therefore be assigned and unpaid,
/// which is a legitimate state the Finance screen surfaces.
class PlanAssignmentsCubit extends Cubit<PlanAssignmentsState> {
  PlanAssignmentsCubit(this._repository)
      : super(const PlanAssignmentsState(byKidId: {}));

  final PlansRepository _repository;

  /// Loads one kid's assignment on demand.
  ///
  /// There is no bulk endpoint — the roster carries a `plan_label` for display,
  /// and the full assignment is only needed on a child's own screen. Fetching
  /// per kid keeps this honest rather than inventing a batch call the contract
  /// does not have.
  Future<void> loadForKid(
    String kidId, {
    required String kidName,
    required String parentName,
    required String parentPhone,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final record = await _repository.fetchAssignment(kidId);
      if (record == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      emit(state.copyWith(
        byKidId: {
          ...state.byKidId,
          kidId: PlanAssignment(
            kidId: kidId,
            kidName: kidName,
            parentName: parentName,
            parentPhone: parentPhone,
            categoryId: record.planCategory,
            lineItemId: record.planId,
            assignedAt: record.assignedAt,
          ),
        },
        isLoading: false,
      ));
    } on ApiException catch (exception) {
      emit(state.copyWith(isLoading: false, error: exception));
    }
  }

  /// Assigns [assignment.lineItemId] to the kid. Optimistic: the change shows
  /// immediately, and is rolled back with an error if the server rejects it.
  Future<void> assign(PlanAssignment assignment) async {
    final rollback = state.byKidId;
    emit(state.copyWith(
      byKidId: {...state.byKidId, assignment.kidId: assignment},
      clearError: true,
    ));

    try {
      await _repository.assignPlan(assignment.kidId, assignment.lineItemId);
    } on ApiException catch (exception) {
      emit(state.copyWith(byKidId: rollback, error: exception));
    }
  }

  PlanAssignment? forKid(String kidId) => state.byKidId[kidId];
}
