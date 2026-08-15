import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
    required this.overtimeAmount,
    required this.totalDue,
    required this.outstanding,
    this.amountPaid = 0,
    this.currency = '',
    this.parentPhone = '',
    this.isPaid = false,
    this.overtimeRate = kDefaultOvertimeHourlyRate,
  });

  /// AED per overtime hour, from Settings at the time this record was
  /// derived — carried on the record so a rate change doesn't silently
  /// restate an invoice already on screen.
  final double overtimeRate;

  /// Overtime is billable, so it has to reach the total.
  ///
  /// Server-supplied — the client renders money, it does not compute it
  /// (contract §2). A rounding rule or a late-pickup policy living here would
  /// mean the admin app and the parent app could eventually disagree about what
  /// a parent owes.
  final double overtimeAmount;

  final double totalDue;

  /// Already settled against this invoice.
  final double amountPaid;

  /// What is still owed.
  final double outstanding;

  final String currency;

  /// Builds a record from `GET /admin/finance/balances` (contract §4).
  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final kidId = json['kid_id'] as String;
    return PaymentRecord(
      id: kidId,
      parentName: json['guardian_name'] as String? ?? '',
      childName: json['kid_full_name'] as String? ?? '',
      baseFee: _num(json['base_fee']),
      overtimeHours: _num(json['overtime_hours']),
      overtimeRate: _num(json['overtime_rate']),
      overtimeAmount: _num(json['overtime_amount']),
      penaltyAmount: _num(json['penalty_amount']),
      totalDue: _num(json['total_due']),
      amountPaid: _num(json['amount_paid']),
      outstanding: _num(json['outstanding']),
      isPaid: json['is_paid'] as bool? ?? false,
      currency: json['currency'] as String? ?? '',
      parentPhone: json['guardian_phone'] as String? ?? '',
      avatarColor: avatarColorFor(kidId),
    );
  }

  static double _num(Object? value) => (value as num?)?.toDouble() ?? 0;
}

/// One deterministic avatar tint per kid, so a re-render never flickers
/// between colours. Presentation, not data — the server does not send it.
Color avatarColorFor(String kidId) =>
    AppColors.avatarPalette[kidId.hashCode.abs() % AppColors.avatarPalette.length];
