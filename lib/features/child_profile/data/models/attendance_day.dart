/// One calendar day in the Attendance Log tab.
///
/// `hours == null` means the kid was not checked in that day (weekend,
/// absence, or a day outside the loaded month shown for grid alignment).
class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.inCurrentMonth,
    this.hours,
  });

  final DateTime date;
  final bool inCurrentMonth;
  final double? hours;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
