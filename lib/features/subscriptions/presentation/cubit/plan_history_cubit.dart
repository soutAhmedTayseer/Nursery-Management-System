import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/subscription_plan.dart';
import '../../data/repositories/plans_repository.dart';

/// Per-kid log of plan changes, kept at app root (see bootstrap.dart) so it
/// survives navigation.
///
/// The server appends a row on every successful assignment and denormalizes
/// the plan names, so history still reads correctly after a plan is renamed or
/// deactivated (contract §2 `PlanChange`).
class PlanHistoryCubit extends Cubit<Map<String, List<PlanChangeEntry>>> {
  PlanHistoryCubit(this._repository) : super(const {});

  final PlansRepository _repository;

  List<PlanChangeEntry> forKid(String kidId) => state[kidId] ?? const [];

  Future<void> loadForKid(String kidId) async {
    try {
      final changes = await _repository.fetchPlanHistory(kidId);
      emit({
        ...state,
        kidId: [
          for (final change in changes)
            PlanChangeEntry(
              date: change.changedAt,
              oldPlanLabel: change.oldPlanName ?? '',
              newPlanLabel: change.newPlanName,
              changedBy: change.changedBy,
            ),
        ],
      });
    } on ApiException {
      // History is a supporting panel, not the reason the screen exists. A
      // failure here leaves the last known list rather than blanking the
      // screen the admin came for; the assignment itself reports its own
      // errors through PlanAssignmentsCubit.
    }
  }
}
