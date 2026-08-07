/// Who the app attributes actions to until real accounts and roles exist.
/// Every audit entry is stamped with this, so swapping it for the signed-in
/// user later is a one-line change at the call sites.
const String kCurrentAdminName = 'Admin';

/// What kind of change an [AuditEntry] records. Kept as an enum (rather
/// than a free-text string) so a future admin/sub-admin roles screen can
/// filter the log by action without parsing prose.
enum AuditAction { invoiceMarkedPaid, invoiceIssued }

/// One immutable line in the activity log: who did what, to whom, when.
///
/// Marking an invoice paid can't be undone, so there has to be a record of
/// who did it. [actor] is a placeholder until real accounts exist — once
/// roles land, this is the field a head admin filters their sub-admins by.
class AuditEntry {
  const AuditEntry({
    required this.action,
    required this.actor,
    required this.subjectId,
    required this.subjectName,
    required this.at,
    this.amount,
  });

  final AuditAction action;
  final String actor;

  /// The kid the invoice belongs to.
  final String subjectId;
  final String subjectName;
  final DateTime at;

  /// Invoice total at the moment of the action, in AED.
  final double? amount;
}
