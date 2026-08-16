import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/testing/attendance_store.dart';

void main() {
  group('AttendanceRecord overtime', () {
    final checkIn = DateTime(2026, 5, 4, 8, 0);

    test('is zero when the child left within their contracted hours', () {
      final record = AttendanceRecord(checkIn: checkIn, checkOut: checkIn.add(const Duration(hours: 3)));
      expect(record.overtimeHours(3), 0);
      expect(record.overtimeWindow(3), isNull);
    });

    test('counts only the hours past the plan', () {
      final record = AttendanceRecord(checkIn: checkIn, checkOut: checkIn.add(const Duration(hours: 5, minutes: 30)));
      expect(record.overtimeHours(3), closeTo(2.5, 0.001));
    });

    test('reports the exact window the child overran', () {
      final record = AttendanceRecord(checkIn: checkIn, checkOut: checkIn.add(const Duration(hours: 5)));
      final window = record.overtimeWindow(3)!;
      expect(window.from, DateTime(2026, 5, 4, 11, 0)); // 08:00 + 3h allowed
      expect(window.to, DateTime(2026, 5, 4, 13, 0));
    });

    test('a full-day plan (null allowance) never accrues overtime', () {
      final record = AttendanceRecord(checkIn: checkIn, checkOut: checkIn.add(const Duration(hours: 11)));
      expect(record.overtimeHours(null), 0);
      expect(record.overtimeWindow(null), isNull);
    });

    test('an open session has no overtime window yet', () {
      final record = AttendanceRecord(checkIn: checkIn);
      expect(record.isOpen, isTrue);
      expect(record.overtimeWindow(3), isNull);
    });
  });

  group('AttendanceStore check-in/out', () {
    test('check-in opens a record and check-out closes it', () {
      final store = AttendanceStore.instance;
      const kidId = 'test-kid-checkin';
      final at = DateTime.now().subtract(const Duration(hours: 2));

      store.checkIn(kidId, at);
      expect(store.openRecord(kidId), isNotNull);

      store.checkOut(kidId, at.add(const Duration(hours: 2)));
      expect(store.openRecord(kidId), isNull);
      expect(store.recordOn(kidId, at)!.hours, closeTo(2, 0.001));
    });

    test('checking in twice does not open a second record', () {
      final store = AttendanceStore.instance;
      const kidId = 'test-kid-double';
      final at = DateTime.now();

      store.checkIn(kidId, at);
      store.checkIn(kidId, at.add(const Duration(minutes: 5)));

      expect(store.forKid(kidId).length, 1);
    });

    test('returning the same day resumes that day, not a second record', () {
      final store = AttendanceStore.instance;
      const kidId = 'test-kid-return';
      // A fixed mid-morning stamp, not `DateTime.now() - 6h`: run before about
      // 06:00 that lands on the previous day, so `morning + 3h` crosses
      // midnight and the store correctly records two days instead of one.
      final now = DateTime.now();
      final morning = DateTime(now.year, now.month, now.day, 8);

      store.checkIn(kidId, morning);
      store.checkOut(kidId, morning.add(const Duration(hours: 2)));
      store.checkIn(kidId, morning.add(const Duration(hours: 3))); // came back
      store.checkOut(kidId, morning.add(const Duration(hours: 5)));

      // One cell on the calendar, one entry for billing — measured from the
      // first arrival to the last departure.
      expect(store.forKid(kidId).length, 1);
      expect(store.recordOn(kidId, morning)!.hours, closeTo(5, 0.001));
    });

    test('seeded history only covers weekdays and stays in the past', () {
      final store = AttendanceStore.instance;
      const kidId = 'test-kid-seed';
      store.seedKid(kidId, 3);

      final records = store.forKid(kidId);
      expect(records, isNotEmpty);
      for (final record in records) {
        expect(record.checkIn.weekday, lessThan(DateTime.saturday));
        expect(record.checkIn.isBefore(DateTime.now()), isTrue);
      }
    });

    test('seeding is idempotent per kid', () {
      final store = AttendanceStore.instance;
      const kidId = 'test-kid-idempotent';
      store.seedKid(kidId, 3);
      final first = store.forKid(kidId).length;
      store.seedKid(kidId, 3);
      expect(store.forKid(kidId).length, first);
    });
  });
}
