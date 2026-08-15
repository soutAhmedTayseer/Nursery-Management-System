import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/plan_assignment.dart';

class PlanAssignmentsState {
  const PlanAssignmentsState({
    required this.byKidId,
    this.isLoading = false,
    this.error,
  });

  final Map<String, PlanAssignment> byKidId;

  final bool isLoading;

  /// Set when an assignment failed to save. The map is rolled back at the same
  /// time, so a rejected assignment is never left on screen looking applied.
  final ApiException? error;

  PlanAssignmentsState copyWith({
    Map<String, PlanAssignment>? byKidId,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) =>
      PlanAssignmentsState(
        byKidId: byKidId ?? this.byKidId,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}
