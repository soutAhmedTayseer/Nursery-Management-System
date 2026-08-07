import '../../data/models/attendance_day.dart';

class AttendanceState {
  const AttendanceState({required this.month, required this.days});

  /// First day of the currently viewed month.
  final DateTime month;

  /// Full calendar grid, including in-month + leading/trailing days.
  final List<AttendanceDay> days;

  List<AttendanceDay> get inMonthDays => days.where((d) => d.inCurrentMonth).toList();

  int get presentDaysCount => inMonthDays.where((d) => d.hours != null).length;

  double get totalHours => inMonthDays.fold(0.0, (sum, d) => sum + (d.hours ?? 0));

  double get averageDailyStay => presentDaysCount == 0 ? 0 : totalHours / presentDaysCount;

  /// Days the child stayed past their contracted hours, and by how much in
  /// total — the same figures Finance bills overtime from.
  List<AttendanceDay> get overtimeDays => inMonthDays.where((d) => d.hasOvertime).toList();

  double get totalOvertimeHours => inMonthDays.fold(0.0, (sum, d) => sum + d.overtimeHours);
}
