import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/repositories/attendance_repository.dart';
import 'attendance_state.dart';

/// Drives the Attendance Log calendar off `GET /kids/{id}/sessions`.
///
/// Asynchronous, unlike the version that read the in-memory ledger: a month is
/// fetched, so it can be loading or fail, and the tab renders both. Each day's
/// contracted hours come from its own session (contract §2 `allowed_hours`), so
/// history stays correct across a plan change instead of assuming the current
/// plan always applied.
class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this.kidId, this._repository)
      : super(AttendanceState(
          month: DateTime(DateTime.now().year, DateTime.now().month),
          days: const [],
          isLoading: true,
        ));

  final String kidId;
  final AttendanceRepository _repository;

  Future<void> load() => _loadMonth(state.month);

  Future<void> previousMonth() =>
      _loadMonth(DateTime(state.month.year, state.month.month - 1));

  Future<void> nextMonth() =>
      _loadMonth(DateTime(state.month.year, state.month.month + 1));

  Future<void> _loadMonth(DateTime month) async {
    emit(state.copyWith(month: month, isLoading: true, clearError: true));
    try {
      final days = await _repository.fetchMonth(kidId, month);
      emit(state.copyWith(days: days, isLoading: false, clearError: true));
    } on ApiException catch (exception) {
      // Keep the month so the header still reads correctly, and clear the grid
      // rather than leaving another month's days under a new title.
      emit(state.copyWith(days: const [], isLoading: false, error: exception));
    }
  }
}
