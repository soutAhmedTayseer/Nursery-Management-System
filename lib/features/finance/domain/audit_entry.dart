/// What kind of change an [AuditEntry] records (contract §2 action list).
///
/// An enum rather than free text so the log can be filtered by action without
/// parsing prose. Anything the server sends that this build does not know maps
/// to [unknown] instead of failing — the backend may log actions added after
/// this app shipped.
enum AuditAction {
  invoiceMarkedPaid,
  chargeAdded,
  planAssigned,
  kidApproved,
  kidRejected,
  kidDeactivated,
  sessionConfirmed,
  sessionRejected,
  subscriptionRecorded,
  adminCreated,
  adminRevoked,
  unknown;

  static AuditAction fromValue(String value) => switch (value) {
        'invoice_marked_paid' => invoiceMarkedPaid,
        'charge_added' => chargeAdded,
        'plan_assigned' => planAssigned,
        'kid_approved' => kidApproved,
        'kid_rejected' => kidRejected,
        'kid_deactivated' => kidDeactivated,
        'session_confirmed' => sessionConfirmed,
        'session_rejected' => sessionRejected,
        'subscription_recorded' => subscriptionRecorded,
        'admin_created' => adminCreated,
        'admin_revoked' => adminRevoked,
        _ => unknown,
      };
}

/// One immutable line in the activity log: who did what, to whom, when.
///
/// **Written by the server, never by this app** (contract §2). A trail the
/// client can append to is one the person being audited can forge, which is the
/// whole reason the log exists — so there is no constructor call anywhere
/// outside [AuditEntry.fromJson].
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.subjectId,
    required this.subjectName,
    required this.at,
    this.amount,
  });

  final String id;
  final AuditAction action;

  /// The admin who performed it. Denormalized server-side so the log still
  /// reads correctly after an admin account is revoked.
  final String actor;

  final String subjectId;
  final String subjectName;
  final DateTime at;

  /// Amount involved, for money actions.
  final double? amount;

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'] as String,
        action: AuditAction.fromValue(json['action'] as String? ?? ''),
        actor: json['actor_name'] as String? ?? '',
        subjectId: json['subject_id'] as String? ?? '',
        subjectName: json['subject_name'] as String? ?? '',
        at: DateTime.parse(json['at'] as String),
        amount: (json['amount'] as num?)?.toDouble(),
      );
}
