import 'package:flutter/material.dart';

/// Fallback overtime rate, used only where no admin setting is in reach
/// (model defaults, tests). The live figure comes from Settings — see
/// `AppSettings.overtimeHourlyRate`.
const double kDefaultOvertimeHourlyRate = 25;

/// Fallback late-pickup policy, same story as the rate above — the live
/// figures come from `AppSettings.latePickupGraceMinutes` / `latePickupFine`.
const int kDefaultLatePickupGraceMinutes = 15;
const double kDefaultLatePickupFine = 50;

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
    this.overtimeRate = kDefaultOvertimeHourlyRate,
  });

  /// AED per overtime hour, from Settings at the time this record was
  /// derived — carried on the record so a rate change doesn't silently
  /// restate an invoice already on screen.
  final double overtimeRate;

  /// Overtime is billable, so it has to reach the total — it used to be
  /// displayed but never charged, which understated every invoice.
  double get overtimeAmount => overtimeHours * overtimeRate;

  double get totalDue => baseFee + overtimeAmount + penaltyAmount;

  /// What's still owed. A settled invoice contributes nothing to the
  /// nursery's outstanding balance.
  double get outstanding => isPaid ? 0 : totalDue;
}
