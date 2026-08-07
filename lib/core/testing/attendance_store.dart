import 'dart:math';

import 'package:flutter/foundation.dart';

/// One attended day: when the child actually arrived and left.
///
/// Replaces the old "random hours per day" mock — real check-in/out stamps
/// are what let the attendance log show *when* an overrun happened, and let
/// Finance bill overtime off the same numbers the calendar displays.
class AttendanceRecord {
  const AttendanceRecord({required this.checkIn, this.checkOut});

  final DateTime checkIn;

  /// Null while the child is still on site (an open session).
  final DateTime? checkOut;

  /// Midnight of the day this record belongs to.
  DateTime get day => DateTime(checkIn.year, checkIn.month, checkIn.day);

  bool get isOpen => checkOut == null;

  /// Hours on site — counts up live while the session is still open.
  double get hours => (checkOut ?? DateTime.now()).difference(checkIn).inMinutes / 60;

  /// Hours beyond [allowedHours]. Null [allowedHours] means a full-day plan
  /// with no hourly cap, which can't accrue overtime.
  double overtimeHours(int? allowedHours) {
    if (allowedHours == null) return 0;
    final extra = hours - allowedHours;
    return extra > 0 ? extra : 0;
  }

  /// The window the child stayed past their plan, e.g. 14:00 → 16:30.
  /// Null when there's no overrun (or the session is still open).
  ({DateTime from, DateTime to})? overtimeWindow(int? allowedHours) {
    if (allowedHours == null || checkOut == null) return null;
    final allowedUntil = checkIn.add(Duration(hours: allowedHours));
    if (!checkOut!.isAfter(allowedUntil)) return null;
    return (from: allowedUntil, to: checkOut!);
  }
}

/// In-memory attendance ledger for the whole nursery — the single source of
/// truth behind the attendance calendar, overtime billing, the revenue
/// chart, and the dashboard's per-day figures.
///
/// Seeded with a few months of plausible history per child so the app has
/// something to show before a backend exists, but clock-in/out writes
/// straight into it, so today's real activity and the seeded past live in
/// the same place. Static/in-memory (like the sessions seed) — it survives
/// navigation, not an app restart.
class AttendanceStore {
  AttendanceStore._();

  static final AttendanceStore instance = AttendanceStore._();

  final Map<String, List<AttendanceRecord>> _byKidId = {};

  /// How many months of history to fabricate behind today.
  static const _seededMonths = 4;

  /// Drops every record. The store is a singleton, so without this a test
  /// inherits whatever the test before it checked in — which silently
  /// inflates overtime totals and makes billing assertions read as if the
  /// maths were wrong.
  @visibleForTesting
  void clear() => _byKidId.clear();

  /// Seeds [kidId]'s history. [allowedHours] shapes how often, and by how
  /// much, the child overran their plan. Idempotent per kid.
  void seedKid(String kidId, int? allowedHours) {
    if (_byKidId.containsKey(kidId)) return;
    final random = Random(kidId.hashCode);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(now.year, now.month - _seededMonths, 1);
    final records = <AttendanceRecord>[];

    for (var day = start; day.isBefore(today); day = day.add(const Duration(days: 1))) {
      final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      if (isWeekend) continue;
      if (random.nextDouble() > 0.85) continue; // ~15% absence

      // Arrivals cluster around 07:30–09:00 in 15-minute steps.
      final checkIn = day.add(Duration(minutes: 7 * 60 + 30 + random.nextInt(7) * 15));
      final base = allowedHours ?? 9;
      // ~30% of days run long, by 30 minutes up to 2.5 hours.
      final overran = random.nextDouble() < 0.3;
      final extraMinutes = overran ? 30 + random.nextInt(5) * 30 : -random.nextInt(3) * 15;
      final stayMinutes = base * 60 + extraMinutes;

      records.add(AttendanceRecord(
        checkIn: checkIn,
        checkOut: checkIn.add(Duration(minutes: stayMinutes)),
      ));
    }
    _byKidId[kidId] = records;
  }

  List<AttendanceRecord> forKid(String kidId) => _byKidId[kidId] ?? const [];

  /// [kidId]'s records inside [month] (any day in the target month).
  List<AttendanceRecord> forMonth(String kidId, DateTime month) {
    return forKid(kidId)
        .where((r) => r.checkIn.year == month.year && r.checkIn.month == month.month)
        .toList();
  }

  AttendanceRecord? recordOn(String kidId, DateTime day) {
    for (final record in forKid(kidId)) {
      if (record.day == DateTime(day.year, day.month, day.day)) return record;
    }
    return null;
  }

  AttendanceRecord? openRecord(String kidId) {
    for (final record in forKid(kidId)) {
      if (record.isOpen) return record;
    }
    return null;
  }

  /// All records across every child on [day] — backs the dashboard's
  /// per-day figures.
  Map<String, AttendanceRecord> allOn(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    final result = <String, AttendanceRecord>{};
    for (final entry in _byKidId.entries) {
      for (final record in entry.value) {
        if (record.day == target) result[entry.key] = record;
      }
    }
    return result;
  }

  void checkIn(String kidId, DateTime at) {
    if (openRecord(kidId) != null) return; // already on site
    final records = _byKidId.putIfAbsent(kidId, () => []);
    // ponytail: one record per day. A child who leaves and returns resumes
    // the same day's record rather than opening a second one, so the
    // calendar (which shows one cell per day) and billing (which sums
    // records) can't disagree. Model separate visits per day only if the
    // nursery actually needs to bill them apart.
    final existing = records.indexWhere((r) => r.day == DateTime(at.year, at.month, at.day));
    if (existing != -1) {
      records[existing] = AttendanceRecord(checkIn: records[existing].checkIn);
      return;
    }
    records.add(AttendanceRecord(checkIn: at));
  }

  void checkOut(String kidId, DateTime at) {
    final records = _byKidId[kidId];
    if (records == null) return;
    final index = records.indexWhere((r) => r.isOpen);
    if (index == -1) return;
    records[index] = AttendanceRecord(checkIn: records[index].checkIn, checkOut: at);
  }
}
