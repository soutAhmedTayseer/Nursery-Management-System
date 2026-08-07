import '../../../core/testing/attendance_store.dart';
import 'models/attendance_day.dart';

/// Builds [kidId]'s calendar grid for [anyDayInMonth] from the real
/// [AttendanceStore] ledger — the same records clock-in/out writes to, so
/// checking a child in today shows up on their calendar immediately.
/// [allowedHours] is the child's contracted hours per day (null = full-day
/// plan), used to flag overtime days.
List<AttendanceDay> generateMonthDays(String kidId, DateTime anyDayInMonth, {int? allowedHours}) {
  final month = DateTime(anyDayInMonth.year, anyDayInMonth.month);
  final firstOfMonth = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  // Grid starts on the Monday on/before the 1st (ISO weekday: Mon=1).
  final leadingDays = firstOfMonth.weekday - 1;
  final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));

  // Pad to full weeks (multiple of 7) so the grid is rectangular.
  final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

  final store = AttendanceStore.instance;

  return List.generate(totalCells, (i) {
    final date = gridStart.add(Duration(days: i));
    final inCurrentMonth = date.month == month.month;
    return AttendanceDay(
      date: date,
      inCurrentMonth: inCurrentMonth,
      allowedHours: allowedHours,
      record: inCurrentMonth ? store.recordOn(kidId, date) : null,
    );
  });
}
