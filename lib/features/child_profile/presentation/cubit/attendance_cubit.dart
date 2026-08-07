import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mock_attendance.dart';
import 'attendance_state.dart';

/// Drives the Attendance Log calendar off the shared [AttendanceStore]
/// ledger, so a child clocked in on the Sessions screen appears here right
/// away and their overtime matches what Finance bills.
class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this.kidId, {this.allowedHours}) : super(_buildMonth(kidId, DateTime.now(), allowedHours));

  final String kidId;

  /// Contracted hours per day from the child's plan — null for full-day
  /// plans, which never accrue overtime.
  final int? allowedHours;

  void previousMonth() {
    final current = state.month;
    emit(_buildMonth(kidId, DateTime(current.year, current.month - 1), allowedHours));
  }

  void nextMonth() {
    final current = state.month;
    emit(_buildMonth(kidId, DateTime(current.year, current.month + 1), allowedHours));
  }

  static AttendanceState _buildMonth(String kidId, DateTime anyDayInMonth, int? allowedHours) {
    final month = DateTime(anyDayInMonth.year, anyDayInMonth.month);
    return AttendanceState(
      month: month,
      days: generateMonthDays(kidId, month, allowedHours: allowedHours),
    );
  }
}
