import '../../data/models/plan_assignment.dart';

class PlanAssignmentsState {
  const PlanAssignmentsState({required this.byKidId});

  final Map<String, PlanAssignment> byKidId;
}
