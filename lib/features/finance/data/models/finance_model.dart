import 'package:flutter/material.dart';

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

  PaymentRecord({
    required this.id,
    required this.parentName,
    required this.childName,
    required this.baseFee,
    required this.overtimeHours,
    required this.penaltyAmount,
    required this.avatarColor,
    this.parentPhone = '',
  });

  double get totalDue => baseFee + penaltyAmount;
}
