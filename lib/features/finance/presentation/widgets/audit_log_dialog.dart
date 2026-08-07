import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/audit_entry.dart';
import '../cubit/audit_log_cubit.dart';

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
    return Dialog(
      backgroundColor: Colors.white,
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
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'audit_log_subtitle'.tr(),
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 20.w, color: AppColors.textSecondary),
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
                          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
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

  String get _description => switch (entry.action) {
        AuditAction.invoiceMarkedPaid =>
          'audit_action_invoice_marked_paid'.tr(namedArgs: {'child': entry.subjectName}),
        AuditAction.invoiceIssued =>
          'audit_action_invoice_issued'.tr(namedArgs: {'child': entry.subjectName}),
      };

  @override
  Widget build(BuildContext context) {
    final at = entry.at;
    final stamp = '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')} '
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
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
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextSpan(
                        text: ' $_description',
                        style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  entry.amount == null ? stamp : '$stamp · ${entry.amount!.toInt()} AED',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
