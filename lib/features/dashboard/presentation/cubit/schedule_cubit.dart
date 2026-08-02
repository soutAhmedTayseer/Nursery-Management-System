import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/schedule_item.dart';
import 'schedule_state.dart';

/// In-memory today-schedule catalog, seeded from [kInitialSchedule] — same
/// pattern as PlansCubit/FinanceCubit, no backend endpoint yet. Always kept
/// sorted by start time — the timeline has no manual ordering.
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleState(items: _sorted(kInitialSchedule)));

  static List<ScheduleItemModel> _sorted(List<ScheduleItemModel> items) => List.of(items)..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  void addItem(ScheduleItemModel item) {
    emit(ScheduleState(items: _sorted([...state.items, item])));
  }

  void updateItem(ScheduleItemModel item) {
    emit(ScheduleState(items: _sorted([for (final i in state.items) if (i.id == item.id) item else i])));
  }

  void deleteItem(String id) {
    emit(ScheduleState(items: state.items.where((i) => i.id != id).toList()));
  }
}
