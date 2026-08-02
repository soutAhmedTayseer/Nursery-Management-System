import 'package:flutter/material.dart';

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

/// Builds the finance ledger from real subscription data: one row per
/// assigned kid, base fee from their plan's price, overtime/penalty from
/// FinanceCubit's per-kid extras. Shared by FinanceScreen and the dashboard's
/// Accounts card so "pending dues" never drifts between the two.
List<PaymentRecord> derivePaymentRecords(PlanAssignmentsState assignments, PlansState plans, FinanceState finance) {
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
      overtimeHours: extras.overtimeHours,
      penaltyAmount: extras.penaltyAmount,
      avatarColor: _avatarColorFor(assignment.kidId),
      parentPhone: assignment.parentPhone,
    ));
  }
  return records;
}
