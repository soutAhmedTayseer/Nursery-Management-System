import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/plan_assignment.dart';
import 'plan_assignments_state.dart';

/// Which kid is on which plan — app-root state (see bootstrap.dart) so it
/// survives navigation, unlike the old per-widget plan that reset when the
/// admin left a child's Financial Dues tab. No backend endpoint yet, so
/// this is in-memory, seeded with a few demo assignments.
class PlanAssignmentsCubit extends Cubit<PlanAssignmentsState> {
  PlanAssignmentsCubit({Map<String, PlanAssignment>? seed})
      : super(PlanAssignmentsState(byKidId: seed ?? _seed));

  static final _seed = <String, PlanAssignment>{
    for (final a in [
      PlanAssignment(
        kidId: 'seed-1',
        kidName: 'Leo Mitchell',
        parentName: 'Sarah Mitchell',
        parentPhone: '971501234567',
        categoryId: 'monthly_packages',
        lineItemId: 'mp_full_5d',
        assignedAt: DateTime(2026, 1, 1),
      ),
      PlanAssignment(
        kidId: 'seed-2',
        kidName: 'Amara Khan',
        parentName: 'James Khan',
        parentPhone: '971502345678',
        categoryId: 'monthly_packages',
        lineItemId: 'mp_8h_5d',
        assignedAt: DateTime(2026, 1, 1),
      ),
      PlanAssignment(
        kidId: 'seed-3',
        kidName: 'Noah Watson',
        parentName: 'Emma Watson',
        parentPhone: '971503456789',
        categoryId: 'daily_subscription',
        lineItemId: 'ds_full',
        assignedAt: DateTime(2026, 1, 1),
      ),
    ])
      a.kidId: a,
  };

  void assign(PlanAssignment assignment) {
    emit(PlanAssignmentsState(byKidId: {...state.byKidId, assignment.kidId: assignment}));
  }

  PlanAssignment? forKid(String kidId) => state.byKidId[kidId];
}
