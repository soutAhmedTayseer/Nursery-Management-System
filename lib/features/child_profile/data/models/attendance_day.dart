import '../../../../core/testing/attendance_store.dart';

/// One calendar day in the Attendance Log tab.
///
/// `record == null` means the kid was not checked in that day (weekend,
/// absence, or a day outside the loaded month shown for grid alignment).
class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.inCurrentMonth,
    required this.allowedHours,
    this.record,
  });

  final DateTime date;
  final bool inCurrentMonth;

  /// The child's contracted hours per day — null for full-day plans, which
  /// never accrue overtime.
  final int? allowedHours;

  /// The real check-in/out stamps for this day, if the child attended.
  final AttendanceRecord? record;

  double? get hours => record?.hours;

  double get overtimeHours => record?.overtimeHours(allowedHours) ?? 0;

  bool get hasOvertime => overtimeHours > 0;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
