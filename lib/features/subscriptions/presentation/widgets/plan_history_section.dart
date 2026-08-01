import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_plan.dart';
import '../utils/subscription_report.dart';

class PlanHistorySection extends StatelessWidget {
  final String childName;
  final String parentName;
  final String parentPhone;
  final String currentPlanTitle;
  final String currentPlanPrice;
  final DateTime startDate;
  final List<PlanChangeEntry> history;

  const PlanHistorySection({
    super.key,
    required this.childName,
    required this.parentName,
    required this.parentPhone,
    required this.currentPlanTitle,
    required this.currentPlanPrice,
    required this.startDate,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8.h,
            children: [
              Text('plan_history_title'.tr(namedArgs: {'childName': childName}), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => exportSubscriptionReportCsv(
                      context: context,
                      childName: childName,
                      parentName: parentName,
                      planTitle: currentPlanTitle,
                      planPrice: currentPlanPrice,
                      startDate: startDate,
                      history: history,
                    ),
                    icon: const Icon(Icons.download, color: Colors.green, size: 16),
                    label: Text('plan_history_export_report'.tr(), style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                  TextButton.icon(
                    onPressed: () => sendSubscriptionReportViaWhatsapp(
                      context: context,
                      parentPhone: parentPhone,
                      childName: childName,
                      parentName: parentName,
                      planTitle: currentPlanTitle,
                      planPrice: currentPlanPrice,
                      startDate: startDate,
                      history: history,
                    ),
                    icon: Icon(Icons.chat_bubble_rounded, color: AppColors.whatsappGreen, size: 16),
                    label: Text('plan_history_send_whatsapp'.tr(), style: TextStyle(color: AppColors.whatsappGreen, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),

          if (history.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text('plan_history_no_entries'.tr(), style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
            )
          else ...[
            Row(
              children: [
                Expanded(flex: 2, child: Text('plan_history_col_date'.tr(), style: _headerStyle())),
                Expanded(flex: 2, child: Text('plan_history_col_old_plan'.tr(), style: _headerStyle())),
                Expanded(flex: 2, child: Text('plan_history_col_new_plan'.tr(), style: _headerStyle())),
                Expanded(flex: 2, child: Text('plan_history_col_changed_by'.tr(), style: _headerStyle())),
              ],
            ),
            Divider(height: 32.h, color: Colors.grey.shade200),
            for (final entry in history) _buildRow(entry),
          ],
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1);

  Widget _buildRow(PlanChangeEntry entry) {
    final dateLabel = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(dateLabel, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
          Expanded(flex: 2, child: Text(entry.oldPlanLabel, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600))),
          Expanded(flex: 2, child: Text(entry.newPlanLabel, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.green.shade700))),
          Expanded(flex: 2, child: Text(entry.changedBy, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
        ],
      ),
    );
  }
}
