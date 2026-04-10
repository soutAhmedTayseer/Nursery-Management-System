import 'package:flutter/material.dart';

class PaymentRecord {
  final String id;
  final String parentName;
  final String childName;
  final double baseFee;
  final double overtimeHours;
  final double penaltyAmount;
  final Color avatarColor;

  PaymentRecord({
    required this.id,
    required this.parentName,
    required this.childName,
    required this.baseFee,
    required this.overtimeHours,
    required this.penaltyAmount,
    required this.avatarColor,
  });

  double get totalDue => baseFee + penaltyAmount;
}
