import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/testing/demo_seed.dart';
import '../../data/models/plan_assignment.dart';
import 'plan_assignments_state.dart';

/// Which kid is on which plan — app-root state (see bootstrap.dart) so it
/// survives navigation, unlike the old per-widget plan that reset when the
/// admin left a child's Financial Dues tab. No backend endpoint yet, so
/// this is in-memory, seeded from the shared demo roster (same kid ids the
/// Sessions grid shows, so Finance and Sessions can't disagree on who's
/// enrolled).
class PlanAssignmentsCubit extends Cubit<PlanAssignmentsState> {
  PlanAssignmentsCubit({Map<String, PlanAssignment>? seed})
      : super(PlanAssignmentsState(byKidId: seed ?? _seed));

  static final _seed = <String, PlanAssignment>{
    for (final child in kDemoChildren) child.id: child.assignment,
  };

  void assign(PlanAssignment assignment) {
    emit(PlanAssignmentsState(byKidId: {...state.byKidId, assignment.kidId: assignment}));
  }

  PlanAssignment? forKid(String kidId) => state.byKidId[kidId];
}
