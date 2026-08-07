import 'package:flutter/material.dart';

import '../../../core/testing/attendance_store.dart';
import '../../settings/data/app_settings.dart';
import '../../subscriptions/data/models/subscription_plan.dart';
import '../../subscriptions/presentation/cubit/plan_assignments_state.dart';
import '../../subscriptions/presentation/cubit/plans_state.dart';
import '../data/models/finance_model.dart';
import '../presentation/cubit/finance_state.dart';

/// Turns a plan's "600 AED" price string into a plain number for math.
double parsePlanPrice(String price) => double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

/// One deterministic avatar tint per kid, so re-derivation (every rebuild)
/// doesn't flicker between random colors.
const _kAvatarPalette = [Color(0xFFDCEDC8), Color(0xFFFFE0B2), Color(0xFFBBDEFB), Color(0xFFF8BBD0), Color(0xFFD1C4E9)];
Color _avatarColorFor(String kidId) => _kAvatarPalette[kidId.hashCode.abs() % _kAvatarPalette.length];

/// Hours [kidId] stayed past their plan during [month], straight from the
/// shared attendance ledger — the same records the child's calendar shows.
double overtimeHoursForMonth(String kidId, int? allowedHours, DateTime month) {
  return AttendanceStore.instance
      .forMonth(kidId, month)
      .fold(0.0, (sum, record) => sum + record.overtimeHours(allowedHours));
}

/// Days in [month] on which [kidId] was collected late enough to be fined.
///
/// The hourly overtime charge starts the moment a child runs past their
/// plan, but the fine only lands after [graceMinutes] — a parent stuck in
/// traffic pays for the time, not a penalty on top.
int latePickupDaysForMonth(
  String kidId,
  int? allowedHours,
  DateTime month,
  int graceMinutes,
) {
  final grace = graceMinutes / 60;
  return AttendanceStore.instance
      .forMonth(kidId, month)
      .where((record) => record.overtimeHours(allowedHours) > grace)
      .length;
}

/// The nursery's late-pickup fine for [kidId] this [month].
///
/// This is what was missing: a penalty could only ever be typed in by hand,
/// so a child with weeks of recorded overtime still showed a 0 penalty, no
/// orange row, and never matched the "with penalty" filter. Now overtime in
/// the ledger produces a fine on its own, and an admin override only
/// *replaces* it.
double latePickupPenalty(
  String kidId,
  int? allowedHours,
  DateTime month, {
  required int graceMinutes,
  required double finePerDay,
}) {
  return latePickupDaysForMonth(kidId, allowedHours, month, graceMinutes) * finePerDay;
}

/// Builds the finance ledger from real subscription data: one row per
/// assigned kid, base fee from their plan's price, overtime computed from
/// their attendance (unless an admin overrode it), penalty and paid status
/// from FinanceCubit. Shared by FinanceScreen and the dashboard so "pending
/// dues" never drifts between the two.
List<PaymentRecord> derivePaymentRecords(
  PlanAssignmentsState assignments,
  PlansState plans,
  FinanceState finance, {
  DateTime? month,
  // The whole policy travels together rather than one named knob per figure.
  // Threading them individually is what let the CSV export fall back to the
  // defaults and disagree with the numbers on screen.
  AppSettings settings = const AppSettings(),
}) {
  final targetMonth = month ?? DateTime.now();
  final records = <PaymentRecord>[];
  for (final assignment in assignments.byKidId.values) {
    PlanLineItem? item;
    for (final category in plans.categories) {
      if (category.id != assignment.categoryId) continue;
      for (final line in category.lineItems) {
        if (line.id == assignment.lineItemId) item = line;
      }
    }
    if (item == null) continue; // plan/line item deleted from the catalog since assignment
    final extras = finance.extrasByKidId[assignment.kidId] ?? const FinanceExtras();
    records.add(PaymentRecord(
      id: assignment.kidId,
      parentName: assignment.parentName,
      childName: assignment.kidName,
      baseFee: parsePlanPrice(item.price),
      overtimeHours: extras.overtimeHoursOverride ??
          overtimeHoursForMonth(assignment.kidId, item.hoursPerDay, targetMonth),
      penaltyAmount: extras.penaltyOverride ??
          latePickupPenalty(
            assignment.kidId,
            item.hoursPerDay,
            targetMonth,
            graceMinutes: settings.latePickupGraceMinutes,
            finePerDay: settings.latePickupFine,
          ),
      avatarColor: _avatarColorFor(assignment.kidId),
      parentPhone: assignment.parentPhone,
      isPaid: finance.paidKidIds.contains(assignment.kidId),
      overtimeRate: settings.overtimeHourlyRate,
    ));
  }
  // Alphabetical by child so the ledger reads in a stable order rather than
  // however the assignment map happened to iterate.
  records.sort((a, b) => a.childName.toLowerCase().compareTo(b.childName.toLowerCase()));
  return records;
}

/// Revenue actually earned on [day] across the whole nursery: each attending
/// child's plan fee amortised over the days their cycle covers, plus any
/// overtime they ran up that day. Backs the revenue chart and the
/// dashboard's per-day figures, so both move when real attendance changes.
double revenueForDay(
  PlanAssignmentsState assignments,
  PlansState plans,
  DateTime day, {
  double overtimeRate = kDefaultOvertimeHourlyRate,
}) {
  final attended = AttendanceStore.instance.allOn(day);
  var total = 0.0;
  for (final entry in attended.entries) {
    final assignment = assignments.byKidId[entry.key];
    if (assignment == null) continue;
    PlanLineItem? item;
    for (final category in plans.categories) {
      if (category.id != assignment.categoryId) continue;
      for (final line in category.lineItems) {
        if (line.id == assignment.lineItemId) item = line;
      }
    }
    if (item == null) continue;
    final perDay = parsePlanPrice(item.price) / (item.daysPerCycle == 0 ? 1 : item.daysPerCycle);
    total += perDay + entry.value.overtimeHours(item.hoursPerDay) * overtimeRate;
  }
  return total;
}

/// [revenueForDay] summed over every day in `[from, to)`.
double revenueForRange(
  PlanAssignmentsState assignments,
  PlansState plans,
  DateTime from,
  DateTime to, {
  double overtimeRate = kDefaultOvertimeHourlyRate,
}) {
  var total = 0.0;
  for (var day = from; day.isBefore(to); day = day.add(const Duration(days: 1))) {
    total += revenueForDay(assignments, plans, day, overtimeRate: overtimeRate);
  }
  return total;
}
