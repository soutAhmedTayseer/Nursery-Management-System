import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/attendance_store.dart';
import '../../../../core/testing/fake_failure_switch.dart';
import '../models/attendance_day.dart';

/// One kid's attendance calendar, built from `GET /kids/{id}/sessions`.
abstract class AttendanceRepository {
  /// The full calendar grid for the month containing [anyDayInMonth],
  /// including the leading and trailing days that pad it to whole weeks.
  Future<List<AttendanceDay>> fetchMonth(String kidId, DateTime anyDayInMonth);
}

/// Lays out a rectangular month grid: Monday-first, padded to whole weeks.
/// Shared by both implementations so the offline and online calendars are
/// the same shape.
List<AttendanceDay> buildGrid(
  DateTime anyDayInMonth,
  AttendanceDay Function(DateTime date, bool inCurrentMonth) cell,
) {
  final month = DateTime(anyDayInMonth.year, anyDayInMonth.month);
  final firstOfMonth = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  // Grid starts on the Monday on/before the 1st (ISO weekday: Mon=1).
  final leadingDays = firstOfMonth.weekday - 1;
  final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));
  final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

  return List.generate(totalCells, (i) {
    final date = gridStart.add(Duration(days: i));
    return cell(date, date.month == month.month);
  });
}

class ApiAttendanceRepository implements AttendanceRepository {
  ApiAttendanceRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AttendanceDay>> fetchMonth(
    String kidId,
    DateTime anyDayInMonth,
  ) async {
    final month = DateTime(anyDayInMonth.year, anyDayInMonth.month);
    final response = await _client.get<Map<String, dynamic>>(
      '/kids/$kidId/sessions',
      queryParameters: {
        'from': _date(month),
        'to': _date(DateTime(month.year, month.month + 1)),
        // One month of a single kid's sessions fits one page comfortably.
        'page_size': 200,
      },
    );

    final sessions =
        PaginatedResult.fromJson(response.data!, Session.fromJson).items;

    // Sessions arrive as a flat list; the calendar needs them keyed by day.
    final byDay = <DateTime, Session>{};
    for (final session in sessions) {
      final checkedInAt = session.checkedInAt;
      if (checkedInAt == null) continue;
      byDay[DateTime(checkedInAt.year, checkedInAt.month, checkedInAt.day)] =
          session;
    }

    return buildGrid(anyDayInMonth, (date, inCurrentMonth) {
      final session = inCurrentMonth ? byDay[date] : null;
      final checkedInAt = session?.checkedInAt;
      return AttendanceDay(
        date: date,
        inCurrentMonth: inCurrentMonth,
        // Per-session, so a plan change mid-history stays correct.
        allowedHours: session?.allowedHours?.round(),
        record: checkedInAt == null
            ? null
            : AttendanceRecord(
                checkIn: checkedInAt,
                checkOut: session!.checkedOutAt,
              ),
      );
    });
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

/// Offline calendar, reading the in-memory ledger clock-in/out writes to.
class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository({required this.failureSwitch, this.allowedHours});

  final FakeFailureSwitch failureSwitch;

  /// The offline ledger has no per-session figure, so one plan-wide value
  /// stands in.
  final int? allowedHours;

  @override
  Future<List<AttendanceDay>> fetchMonth(
    String kidId,
    DateTime anyDayInMonth,
  ) async {
    failureSwitch.maybeThrow();
    final store = AttendanceStore.instance;

    return buildGrid(anyDayInMonth, (date, inCurrentMonth) {
      return AttendanceDay(
        date: date,
        inCurrentMonth: inCurrentMonth,
        allowedHours: allowedHours,
        record: inCurrentMonth ? store.recordOn(kidId, date) : null,
      );
    });
  }
}
