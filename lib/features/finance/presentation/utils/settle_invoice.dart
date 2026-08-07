import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/audit_entry.dart';
import '../cubit/audit_log_cubit.dart';
import '../cubit/finance_cubit.dart';

/// Confirms, settles, and logs — the single path for marking an invoice paid.
///
/// Marking paid can't be undone, so the confirmation and the audit entry are
/// not optional extras: routing every caller (the Finance table, the mobile
/// payment card, the dashboard alert) through here is what stops one of them
/// quietly settling money with no record of who did it.
Future<void> settleInvoice(
  BuildContext context, {
  required String kidId,
  required String childName,
  required double amount,
}) async {
  final confirmed = await ConfirmationDialog.show(
    context,
    title: 'finance_mark_paid_confirm_title'.tr(),
    message: 'finance_mark_paid_confirm_message'.tr(namedArgs: {
      'child': childName,
      'amount': amount.toInt().toString(),
    }),
    confirmLabel: 'finance_mark_paid_confirm_action'.tr(),
  );
  if (!confirmed || !context.mounted) return;

  context.read<FinanceCubit>().markPaid(kidId);
  context.read<AuditLogCubit>().record(AuditEntry(
        action: AuditAction.invoiceMarkedPaid,
        actor: kCurrentAdminName,
        subjectId: kidId,
        subjectName: childName,
        at: DateTime.now(),
        amount: amount,
      ));

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('finance_marked_paid'.tr(namedArgs: {'child': childName}))),
  );
}
