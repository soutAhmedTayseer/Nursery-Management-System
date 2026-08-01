import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_day.dart';
import 'attendance_state.dart';

/// Drives the Attendance Log calendar.
///
/// No backend endpoint for historical daily attendance yet — only today's
/// open/closed session is real. Days are generated deterministically per
/// [kidId] so a given child's calendar looks the same across rebuilds
/// instead of reshuffling on every load.
class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this.kidId) : super(_buildMonth(kidId, DateTime.now()));

  final String kidId;

  void previousMonth() {
    final current = state.month;
    emit(_buildMonth(kidId, DateTime(current.year, current.month - 1)));
  }

  void nextMonth() {
    final current = state.month;
    emit(_buildMonth(kidId, DateTime(current.year, current.month + 1)));
  }

  static AttendanceState _buildMonth(String kidId, DateTime anyDayInMonth) {
    final month = DateTime(anyDayInMonth.year, anyDayInMonth.month);
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Grid starts on the Monday on/before the 1st (ISO weekday: Mon=1).
    final leadingDays = firstOfMonth.weekday - 1;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));

    // Pad to full weeks (multiple of 7) so the grid is rectangular.
    final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

    final random = Random('$kidId-${month.year}-${month.month}'.hashCode);
    final today = DateTime.now();

    return AttendanceState(
      month: month,
      days: List.generate(totalCells, (i) {
        final date = gridStart.add(Duration(days: i));
        final inCurrentMonth = date.month == month.month;
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));

        double? hours;
        if (inCurrentMonth && !isWeekend && !isFuture) {
          // ~85% attendance rate, 6-8.5h range in 0.5h steps.
          final attended = random.nextDouble() < 0.85;
          hours = attended ? 6 + random.nextInt(6) * 0.5 : null;
        }

        return AttendanceDay(date: date, inCurrentMonth: inCurrentMonth, hours: hours);
      }),
    );
  }
}
