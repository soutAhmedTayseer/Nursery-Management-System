import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// Set false when the child's name is already shown elsewhere (e.g.
  /// ChildProfileDetailsScreen's header) to avoid repeating it in the title.
  final bool showChildName;

  const PlanHistorySection({
    super.key,
    required this.childName,
    required this.parentName,
    required this.parentPhone,
    required this.currentPlanTitle,
    required this.currentPlanPrice,
    required this.startDate,
    required this.history,
    this.showChildName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8.h,
            children: [
              Text(
                showChildName ? 'plan_history_title'.tr(namedArgs: {'childName': childName}) : 'plan_history_title_generic'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
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
                    icon: SvgPicture.asset('assets/icons/subscriptions/export_icon.svg', width: 9.3.w, height: 9.3.w),
                    label: Text('plan_history_export_report'.tr(), style: TextStyle(color: AppColors.darkGreen, fontSize: 12.sp, fontWeight: FontWeight.bold)),
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
              child: Text('plan_history_no_entries'.tr(), style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
            )
          else ...[
            Row(
              children: [
                Expanded(flex: 2, child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text('plan_history_col_date'.tr(), style: _headerStyle()))),
                Expanded(flex: 2, child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text('plan_history_col_old_plan'.tr(), style: _headerStyle()))),
                Expanded(flex: 2, child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text('plan_history_col_new_plan'.tr(), style: _headerStyle()))),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('plan_history_col_changed_by'.tr(), textAlign: TextAlign.right, style: _headerStyle()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            for (final entry in history) ...[_buildRow(entry), SizedBox(height: 16.h)],
          ],
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1);

  Widget _buildRow(PlanChangeEntry entry) {
    final dateLabel = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceCream, borderRadius: BorderRadius.circular(16.r)),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(dateLabel, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          Expanded(flex: 2, child: Text(entry.oldPlanLabel, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/icons/subscriptions/history_dot.svg', width: 8.w, height: 8.w),
                SizedBox(width: 4.w),
                Flexible(child: Text(entry.newPlanLabel, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen))),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(entry.changedBy, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
