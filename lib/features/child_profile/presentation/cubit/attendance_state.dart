import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/attendance_day.dart';

class AttendanceState {
  const AttendanceState({
    required this.month,
    required this.days,
    this.isLoading = false,
    this.error,
  });

  /// First day of the currently viewed month.
  final DateTime month;

  /// Full calendar grid, including in-month + leading/trailing days.
  final List<AttendanceDay> days;

  final bool isLoading;

  /// Set when the month failed to load. The calendar is a record of what a
  /// child actually did, so an empty grid must never stand in for one that
  /// could not be fetched.
  final ApiException? error;

  AttendanceState copyWith({
    DateTime? month,
    List<AttendanceDay>? days,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) =>
      AttendanceState(
        month: month ?? this.month,
        days: days ?? this.days,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  List<AttendanceDay> get inMonthDays => days.where((d) => d.inCurrentMonth).toList();

  int get presentDaysCount => inMonthDays.where((d) => d.hours != null).length;

  double get totalHours => inMonthDays.fold(0.0, (sum, d) => sum + (d.hours ?? 0));

  double get averageDailyStay => presentDaysCount == 0 ? 0 : totalHours / presentDaysCount;

  /// Days the child stayed past their contracted hours, and by how much in
  /// total — the same figures Finance bills overtime from.
  List<AttendanceDay> get overtimeDays => inMonthDays.where((d) => d.hasOvertime).toList();

  double get totalOvertimeHours => inMonthDays.fold(0.0, (sum, d) => sum + d.overtimeHours);
}
