import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/core/testing/attendance_store.dart';
import 'package:nursery_management_system/core/testing/fake_failure_switch.dart';
import 'package:nursery_management_system/features/child_profile/data/models/attendance_day.dart';
import 'package:nursery_management_system/features/child_profile/data/repositories/attendance_repository.dart';
import 'package:nursery_management_system/features/child_profile/presentation/cubit/attendance_cubit.dart';
import 'package:nursery_management_system/features/child_profile/presentation/cubit/attendance_state.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockAttendanceRepository extends Mock implements AttendanceRepository {}

const _boom = ApiException(
  code: 'SERVER_ERROR',
  message: 'boom',
  statusCode: 500,
);

/// A grid with one attended day, so `presentDaysCount` has something to find.
List<AttendanceDay> _grid(DateTime month) => buildGrid(month, (date, inMonth) {
      return AttendanceDay(
        date: date,
        inCurrentMonth: inMonth,
        allowedHours: 3,
        record: inMonth && date.day == 3
            ? AttendanceRecord(
                checkIn: DateTime(date.year, date.month, date.day, 8),
                checkOut: DateTime(date.year, date.month, date.day, 13),
              )
            : null,
      );
    });

void main() {
  late _MockAttendanceRepository repository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    repository = _MockAttendanceRepository();
    when(() => repository.fetchMonth(any(), any()))
        .thenAnswer((i) async => _grid(i.positionalArguments[1] as DateTime));
  });

  test('the grid is always whole weeks', () async {
    final days = await FakeAttendanceRepository(
      failureSwitch: FakeFailureSwitch(),
    ).fetchMonth('kid-1', DateTime(2026, 8));

    expect(days.length % 7, 0);
    // Monday-first: the first cell is a Monday.
    expect(days.first.date.weekday, DateTime.monday);
  });

  blocTest<AttendanceCubit, AttendanceState>(
    'load fills the month and reports the attended day',
    build: () => AttendanceCubit('kid-1', repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.presentDaysCount, 1);
      expect(cubit.state.totalHours, 5);
      // 5 hours against a 3-hour plan.
      expect(cubit.state.totalOvertimeHours, 2);
      expect(cubit.state.error, isNull);
    },
  );

  blocTest<AttendanceCubit, AttendanceState>(
    'previousMonth moves the window and refetches',
    build: () => AttendanceCubit('kid-1', repository),
    act: (cubit) async {
      await cubit.load();
      final before = cubit.state.month;
      await cubit.previousMonth();
      expect(cubit.state.month.month, DateTime(before.year, before.month - 1).month);
    },
    verify: (_) => verify(() => repository.fetchMonth('kid-1', any())).called(2),
  );

  blocTest<AttendanceCubit, AttendanceState>(
    'a failed month clears the grid rather than showing an empty one as real',
    setUp: () {
      when(() => repository.fetchMonth(any(), any())).thenThrow(_boom);
    },
    build: () => AttendanceCubit('kid-1', repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      // An empty calendar must never stand in for one that failed to load —
      // it would read as "this child never attended".
      expect(cubit.state.days, isEmpty);
      expect(cubit.state.error, _boom);
      expect(cubit.state.isLoading, isFalse);
    },
  );
}
