import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class AlertsNotificationsSection extends StatelessWidget {
  const AlertsNotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('alerts_header_title'.tr(), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('alerts_mark_all_read'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          ],
        ),
        SizedBox(height: 20.h),

        // Alert Items
        _buildAlertCard(
          isUrgent: true,
          title: 'alerts_overtime_leo'.tr(),
          description: 'alerts_overtime_leo_desc'.tr(),
          borderColor: const Color(0xFF8D6E63),
          icon: Icons.warning_amber_rounded,
          actions: Row(
            children: [
              _buildActionButton('alerts_call_parent'.tr(), isPrimary: true),
              SizedBox(width: 12.w),
              _buildActionButton('alerts_extend_session'.tr(), isPrimary: false),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        _buildAlertCard(
          isUrgent: true,
          title: 'alerts_overtime_amira'.tr(),
          description: 'alerts_overtime_amira_desc'.tr(),
          borderColor: const Color(0xFF8D6E63),
          icon: Icons.warning_amber_rounded,
        ),
        SizedBox(height: 16.h),

        _buildAlertCard(
          isUrgent: false,
          title: 'alerts_finance_sync_title'.tr(),
          description: 'alerts_finance_sync_desc'.tr(),
          borderColor: AppColors.darkGreen,
          icon: Icons.check_circle_outline,
          time: 'alerts_time_2h_ago'.tr(),
        ),
      ],
    );
  }

  Widget _buildAlertCard({required bool isUrgent, required String title, required String description, required Color borderColor, required IconData icon, Widget? actions, String? time}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight( // بيخلي الخط الجانبي ياخد نفس طول الكارت
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Border Indicator
            Container(
              width: 6.w,
              decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), bottomLeft: Radius.circular(24.r))),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: borderColor, size: 24.w),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              if (isUrgent) Text('alerts_urgent_badge'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF8D6E63), letterSpacing: 1)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(description, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.5)),

                          if (actions != null) ...[
                            SizedBox(height: 16.h),
                            actions,
                          ],
                          if (time != null) ...[
                            SizedBox(height: 16.h),
                            Text(time, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, {required bool isPrimary}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF795548) : Colors.transparent, // بني أو شفاف
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFF795548), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      ),
      child: Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : const Color(0xFF795548))),
    );
  }
}