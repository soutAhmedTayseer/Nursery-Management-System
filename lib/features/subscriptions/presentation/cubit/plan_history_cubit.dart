import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/subscription_plan.dart';

/// Per-kid log of plan changes, kept at app root (see bootstrap.dart) so it
/// survives navigation — it used to live inside the Financial Dues tab's
/// widget state, which meant changing a child's plan and leaving the tab
/// silently threw the history away while the plan itself persisted.
class PlanHistoryCubit extends Cubit<Map<String, List<PlanChangeEntry>>> {
  PlanHistoryCubit() : super(const {});

  List<PlanChangeEntry> forKid(String kidId) => state[kidId] ?? const [];

  void record(String kidId, PlanChangeEntry entry) {
    emit({
      ...state,
      kidId: [entry, ...forKid(kidId)],
    });
  }
}
