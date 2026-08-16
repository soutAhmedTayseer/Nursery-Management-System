import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/schedule_item.dart';
import '../../data/repositories/schedule_repository.dart';
import 'schedule_state.dart';

/// The nursery's shared daily routine, backed by `/admin/schedule`.
///
/// Always kept sorted by start time — the timeline has no manual ordering.
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._repository) : super(const ScheduleState());

  final ScheduleRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final items = await _repository.fetchSchedule();
      emit(state.copyWith(items: _sorted(items), isLoading: false, clearError: true));
    } on ApiException catch (exception) {
      emit(state.copyWith(isLoading: false, error: exception));
    }
  }

  Future<void> addItem(ScheduleItemModel item) =>
      _write(() => _repository.createItem(item));

  Future<void> updateItem(ScheduleItemModel item) =>
      _write(() => _repository.updateItem(item));

  Future<void> deleteItem(String id) => _write(() => _repository.deleteItem(id));

  /// Re-reads after every write instead of patching the list locally: the
  /// routine is shared, so another admin may have changed it in the meantime.
  Future<void> _write(Future<void> Function() request) async {
    emit(state.copyWith(clearError: true));
    try {
      await request();
      await load();
    } on ApiException catch (exception) {
      emit(state.copyWith(error: exception));
    }
  }

  static List<ScheduleItemModel> _sorted(List<ScheduleItemModel> items) =>
      List.of(items)..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
}
