import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/testing/attendance_store.dart';
import 'package:nursery_management_system/features/finance/data/models/finance_model.dart';
import 'package:nursery_management_system/features/finance/domain/payment_records.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_state.dart';
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
    final store = AttendanceStore.instance;
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
    expect(record.overtimeAmount, 2 * kOvertimeHourlyRate);
    expect(record.totalDue, 600 + 2 * kOvertimeHourlyRate + 100);
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
}
