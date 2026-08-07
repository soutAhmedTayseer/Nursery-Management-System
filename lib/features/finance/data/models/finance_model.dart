import 'package:flutter/material.dart';

/// What the nursery charges per hour a child stays past their plan.
/// Flat rate for now — a real backend would make this configurable per
/// plan, which is why it lives here rather than being sprinkled inline.
const double kOvertimeHourlyRate = 25;

class PaymentRecord {
  final String id;
  final String parentName;
  final String childName;
  final double baseFee;
  final double overtimeHours;
  final double penaltyAmount;
  final Color avatarColor;

  /// E.164-ish digits only (no `+`), e.g. "971501234567". Empty when unknown.
  final String parentPhone;

  /// Whether the admin has recorded this invoice as settled.
  final bool isPaid;

  PaymentRecord({
    required this.id,
    required this.parentName,
    required this.childName,
    required this.baseFee,
    required this.overtimeHours,
    required this.penaltyAmount,
    required this.avatarColor,
    this.parentPhone = '',
    this.isPaid = false,
  });

  /// Overtime is billable, so it has to reach the total — it used to be
  /// displayed but never charged, which understated every invoice.
  double get overtimeAmount => overtimeHours * kOvertimeHourlyRate;

  double get totalDue => baseFee + overtimeAmount + penaltyAmount;

  /// What's still owed. A settled invoice contributes nothing to the
  /// nursery's outstanding balance.
  double get outstanding => isPaid ? 0 : totalDue;
}
