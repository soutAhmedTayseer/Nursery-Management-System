import '../../../core/testing/attendance_store.dart';
import '../../finance/data/models/finance_model.dart';

enum AlertKind {
  /// A child is on site and has already passed their contracted hours.
  overtimeLive,

  /// A child ran up billable overtime this month that isn't settled yet.
  overtimeBillable,

  /// An unpaid invoice.
  paymentDue,

  /// A child is still checked in unusually late.
  lateCheckout,
}

/// One actionable item on the dashboard. Every field is derived from real
/// app state (attendance ledger + payment records) — there is no filler
/// notification here, so anything shown is something an admin can act on.
class NurseryAlert {
  const NurseryAlert({
    required this.kind,
    required this.kidId,
    required this.kidName,
    required this.parentName,
    required this.parentPhone,
    this.hours = 0,
    this.amount = 0,
  });

  final AlertKind kind;
  final String kidId;
  final String kidName;
  final String parentName;
  final String parentPhone;
  final double hours;
  final double amount;

  bool get isUrgent => kind == AlertKind.overtimeLive || kind == AlertKind.lateCheckout;
}

/// Hour after which a child still on site counts as a late checkout.
const _kLateCheckoutHour = 17;

/// Builds the dashboard's alert list from live attendance and the payment
/// ledger, most urgent first.
List<NurseryAlert> buildNurseryAlerts({
  required List<PaymentRecord> records,
  required Map<String, int?> allowedHoursByKidId,
}) {
  final store = AttendanceStore.instance;
  final now = DateTime.now();
  final alerts = <NurseryAlert>[];

  for (final record in records) {
    final open = store.openRecord(record.id);
    final allowed = allowedHoursByKidId[record.id];

    // On site and already past their plan — the one an admin must act on now.
    if (open != null) {
      final liveOvertime = open.overtimeHours(allowed);
      if (liveOvertime > 0) {
        alerts.add(NurseryAlert(
          kind: AlertKind.overtimeLive,
          kidId: record.id,
          kidName: record.childName,
          parentName: record.parentName,
          parentPhone: record.parentPhone,
          hours: liveOvertime,
        ));
      } else if (now.hour >= _kLateCheckoutHour) {
        alerts.add(NurseryAlert(
          kind: AlertKind.lateCheckout,
          kidId: record.id,
          kidName: record.childName,
          parentName: record.parentName,
          parentPhone: record.parentPhone,
          hours: open.hours,
        ));
      }
    }

    // Billable overtime already accrued this month, still unpaid.
    if (!record.isPaid && record.overtimeHours > 0) {
      alerts.add(NurseryAlert(
        kind: AlertKind.overtimeBillable,
        kidId: record.id,
        kidName: record.childName,
        parentName: record.parentName,
        parentPhone: record.parentPhone,
        hours: record.overtimeHours,
        amount: record.overtimeAmount,
      ));
    }

    if (!record.isPaid && record.totalDue > 0) {
      alerts.add(NurseryAlert(
        kind: AlertKind.paymentDue,
        kidId: record.id,
        kidName: record.childName,
        parentName: record.parentName,
        parentPhone: record.parentPhone,
        amount: record.totalDue,
      ));
    }
  }

  alerts.sort((a, b) {
    if (a.isUrgent == b.isUrgent) return b.amount.compareTo(a.amount);
    return a.isUrgent ? -1 : 1;
  });
  return alerts;
}
