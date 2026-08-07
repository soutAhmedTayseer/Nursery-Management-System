import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/testing/attendance_store.dart';
import 'package:nursery_management_system/features/finance/data/models/finance_model.dart';
import 'package:nursery_management_system/features/finance/domain/payment_records.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_state.dart';
import 'package:nursery_management_system/features/settings/data/app_settings.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/plan_assignment.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plan_assignments_state.dart';
import 'package:nursery_management_system/features/subscriptions/presentation/cubit/plans_state.dart';

/// A kid on a 3-hours/day plan priced at 600 AED.
const _kidId = 'records-test-kid';

PlanAssignmentsState _assignments() => PlanAssignmentsState(byKidId: {
      _kidId: PlanAssignment(
        kidId: _kidId,
        kidName: 'Test Child',
        parentName: 'Test Parent',
        parentPhone: '971500000000',
        categoryId: 'cat',
        lineItemId: 'item',
        assignedAt: DateTime(2026, 1, 1),
      ),
    });

const _plans = PlansState(categories: [
  PlanCategory(
    id: 'cat',
    name: 'Test Category',
    icon: Icons.abc,
    themeColor: Color(0xFF000000),
    lineItems: [PlanLineItem(id: 'item', label: '3 hours / 5 Days', price: '600 AED', hoursPerDay: 3, daysPerCycle: 5)],
  ),
]);

void main() {
  setUp(() {
    // Two attended days this month: one within plan, one 2h over.
    final store = AttendanceStore.instance..clear();
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, 1, 8);
    store.checkIn(_kidId, day);
    store.checkOut(_kidId, day.add(const Duration(hours: 5))); // 2h overtime
  });

  test('overtime is billed into the total, not just displayed', () {
    final record = PaymentRecord(
      id: _kidId,
      parentName: 'p',
      childName: 'c',
      baseFee: 600,
      overtimeHours: 2,
      penaltyAmount: 100,
      avatarColor: const Color(0xFF000000),
    );
    expect(record.overtimeAmount, 2 * kDefaultOvertimeHourlyRate);
    expect(record.totalDue, 600 + 2 * kDefaultOvertimeHourlyRate + 100);
  });

  test('a paid invoice owes nothing even though the total stands', () {
    final record = PaymentRecord(
      id: _kidId,
      parentName: 'p',
      childName: 'c',
      baseFee: 600,
      overtimeHours: 0,
      penaltyAmount: 0,
      avatarColor: const Color(0xFF000000),
      isPaid: true,
    );
    expect(record.totalDue, 600);
    expect(record.outstanding, 0);
  });

  test('derived records read overtime from the attendance ledger', () {
    final records = derivePaymentRecords(_assignments(), _plans, const FinanceState());
    expect(records.single.overtimeHours, closeTo(2, 0.001));
  });

  test('an admin override wins over the computed overtime', () {
    final records = derivePaymentRecords(
      _assignments(),
      _plans,
      const FinanceState(extrasByKidId: {_kidId: FinanceExtras(overtimeHoursOverride: 9)}),
    );
    expect(records.single.overtimeHours, 9);
  });

  test('marking a kid paid flags their record', () {
    final records = derivePaymentRecords(
      _assignments(),
      _plans,
      const FinanceState(paidKidIds: {_kidId}),
    );
    expect(records.single.isPaid, isTrue);
    expect(records.single.outstanding, 0);
  });

  group('late-pickup penalty', () {
    // The bug this group exists for: a child could run overtime every week
    // and still show a 0 penalty, because a penalty was only ever a figure
    // an admin typed in. Nothing derived one from attendance.
    test('a child who ran overtime is fined without an admin touching it', () {
      final record = derivePaymentRecords(_assignments(), _plans, const FinanceState()).single;
      expect(record.overtimeHours, 2);
      expect(record.penaltyAmount, greaterThan(0), reason: 'overtime must produce a fine on its own');
    });

    test('the fine is per late day, not per overtime hour', () {
      const settings = AppSettings(latePickupFine: 50, latePickupGraceMinutes: 15);
      // One late day is seeded, so one fine regardless of how many hours.
      final record = derivePaymentRecords(
        _assignments(), _plans, const FinanceState(), settings: settings,
      ).single;
      expect(record.penaltyAmount, 50);
    });

    test('an overrun inside the grace period is billed but not fined', () {
        final store = AttendanceStore.instance;
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, 2, 8);
      store.checkIn(_kidId, day);
      store.checkOut(_kidId, day.add(const Duration(hours: 3, minutes: 10)));

      // Day 2 alone: 10 minutes over a 15-minute grace is not a late pickup.
      expect(latePickupDaysForMonth(_kidId, 3, now, 15), 1, reason: 'only day 1 is late');
    });

    test('an admin override replaces the policy, and 0 waives the fine', () {
      const waived = FinanceState(extrasByKidId: {_kidId: FinanceExtras(penaltyOverride: 0)});
      expect(derivePaymentRecords(_assignments(), _plans, waived).single.penaltyAmount, 0);

      const raised = FinanceState(extrasByKidId: {_kidId: FinanceExtras(penaltyOverride: 300)});
      expect(derivePaymentRecords(_assignments(), _plans, raised).single.penaltyAmount, 300);
    });

    test('the fine reaches the total due', () {
      final record = derivePaymentRecords(
        _assignments(), _plans, const FinanceState(),
        settings: const AppSettings(overtimeHourlyRate: 25, latePickupFine: 50),
      ).single;
      expect(record.totalDue, 600 + 2 * 25 + 50);
    });
  });
}
