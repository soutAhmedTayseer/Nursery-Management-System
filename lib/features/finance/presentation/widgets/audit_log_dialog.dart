import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/audit_entry.dart';
import '../cubit/audit_log_cubit.dart';
import '../../../../core/theme/app_palette.dart';

/// Read-only view of the activity log. No filters or export yet — when
/// roles land, this is where a head admin picks a sub-admin and sees only
/// their actions.
class AuditLogDialog extends StatelessWidget {
  const AuditLogDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AuditLogCubit>(),
        child: const AuditLogDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      backgroundColor: palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 560.h),
        child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'audit_log_title'.tr(),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: palette.textPrimary),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'audit_log_subtitle'.tr(),
                          style: TextStyle(fontSize: 12.sp, color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 20.w, color: palette.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Flexible(
                child: BlocBuilder<AuditLogCubit, List<AuditEntry>>(
                  builder: (context, entries) {
                    if (entries.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Text(
                          'audit_log_empty'.tr(),
                          style: TextStyle(fontSize: 13.sp, color: palette.textSecondary),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) => _EntryTile(entry: entries[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final AuditEntry entry;

  String get _description {
    final child = {'child': entry.subjectName};
    return switch (entry.action) {
      AuditAction.invoiceMarkedPaid => 'audit_action_invoice_marked_paid'.tr(namedArgs: child),
      AuditAction.chargeAdded => 'audit_action_charge_added'.tr(namedArgs: child),
      AuditAction.planAssigned => 'audit_action_plan_assigned'.tr(namedArgs: child),
      AuditAction.subscriptionRecorded => 'audit_action_subscription_recorded'.tr(namedArgs: child),
      AuditAction.kidApproved => 'audit_action_kid_approved'.tr(namedArgs: child),
      AuditAction.kidRejected => 'audit_action_kid_rejected'.tr(namedArgs: child),
      AuditAction.kidDeactivated => 'audit_action_kid_deactivated'.tr(namedArgs: child),
      AuditAction.sessionConfirmed => 'audit_action_session_confirmed'.tr(namedArgs: child),
      AuditAction.sessionRejected => 'audit_action_session_rejected'.tr(namedArgs: child),
      AuditAction.adminCreated => 'audit_action_admin_created'.tr(namedArgs: child),
      AuditAction.adminRevoked => 'audit_action_admin_revoked'.tr(namedArgs: child),
      // An action this build does not know about, logged by a newer backend.
      AuditAction.unknown => 'audit_action_unknown'.tr(namedArgs: child),
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final at = entry.at;
    final stamp = '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')} '
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.cardMuted,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16.w, color: AppColors.successGreen),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: entry.actor,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
                      ),
                      TextSpan(
                        text: ' $_description',
                        style: TextStyle(fontSize: 13.sp, color: palette.textPrimary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  entry.amount == null ? stamp : '$stamp · ${entry.amount!.toInt()} AED',
                  style: TextStyle(fontSize: 11.sp, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
