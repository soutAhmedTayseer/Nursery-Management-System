import '../enums/subscription_status.dart';

class Subscription {
  const Subscription({
    required this.id,
    required this.kidId,
    required this.planId,
    required this.hoursRemaining,
    required this.hoursTotal,
    required this.purchasedAt,
    required this.recordedBy,
    required this.paymentMethod,
    required this.notes,
    required this.status,
  });

  final String id;
  final String kidId;
  final String planId;
  final double hoursRemaining; // may be negative — overage debt is allowed
  final double hoursTotal;
  final DateTime purchasedAt;
  final String recordedBy; // admin id
  final String paymentMethod; // 'cash' | 'transfer'
  final String? notes;
  final SubscriptionStatus status;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      kidId: json['kid_id'] as String,
      planId: json['plan_id'] as String,
      hoursRemaining: (json['hours_remaining'] as num).toDouble(),
      hoursTotal: (json['hours_total'] as num).toDouble(),
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      recordedBy: json['recorded_by'] as String,
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      status: SubscriptionStatus.fromValue(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kid_id': kidId,
        'plan_id': planId,
        'hours_remaining': hoursRemaining,
        'hours_total': hoursTotal,
        'purchased_at': purchasedAt.toIso8601String(),
        'recorded_by': recordedBy,
        'payment_method': paymentMethod,
        'notes': notes,
        'status': status.value,
      };
}
