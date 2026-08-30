import '../enums/session_status.dart';

class Session {
  const Session({
    required this.id,
    required this.kidId,
    required this.requestedBy,
    required this.requestedById,
    required this.status,
    required this.checkedInAt,
    required this.confirmedBy,
    required this.checkedOutAt,
    required this.checkedOutConfirmedBy,
    required this.hoursDeducted,
    required this.subscriptionId,
    this.allowedHours,
  });

  final String id;
  final String kidId;
  final String requestedBy; // 'guardian' | 'admin'
  final String requestedById;
  final SessionStatus status;
  final DateTime? checkedInAt;
  final String? confirmedBy;
  final DateTime? checkedOutAt;
  final String? checkedOutConfirmedBy;
  final double? hoursDeducted;
  final String? subscriptionId;

  /// Contracted hours per day under whichever subscription was active on this
  /// session's date, or null for a full-day plan. Resolved server-side so the
  /// client is not guessing across plan changes (contract §2).
  final double? allowedHours;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      kidId: json['kid_id'] as String,
      requestedBy: json['requested_by'] as String,
      requestedById: json['requested_by_id'] as String,
      status: SessionStatus.fromValue(json['status'] as String),
      checkedInAt: json['checked_in_at'] == null
          ? null
          : DateTime.parse(json['checked_in_at'] as String),
      confirmedBy: json['confirmed_by'] as String?,
      checkedOutAt: json['checked_out_at'] == null
          ? null
          : DateTime.parse(json['checked_out_at'] as String),
      checkedOutConfirmedBy: json['checked_out_confirmed_by'] as String?,
      hoursDeducted: json['hours_deducted'] == null
          ? null
          : (json['hours_deducted'] as num).toDouble(),
      subscriptionId: json['subscription_id'] as String?,
      allowedHours: (json['allowed_hours'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kid_id': kidId,
        'requested_by': requestedBy,
        'requested_by_id': requestedById,
        'status': status.value,
        'checked_in_at': checkedInAt?.toIso8601String(),
        'confirmed_by': confirmedBy,
        'checked_out_at': checkedOutAt?.toIso8601String(),
        'checked_out_confirmed_by': checkedOutConfirmedBy,
        'hours_deducted': hoursDeducted,
        'subscription_id': subscriptionId,
        'allowed_hours': allowedHours,
      };
}
