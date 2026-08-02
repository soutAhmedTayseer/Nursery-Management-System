import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';

class OvertimeAlert {
  const OvertimeAlert({required this.kidName, required this.overtimeHours});

  final String kidName;
  final double overtimeHours;
}

/// Real overtime alerts, one per kid with overtimeHours > 0 in FinanceCubit
/// — no fake "Finance Sync Complete" filler notification, since there's no
/// real bank-sync feature behind it.
class AlertsNotificationsSection extends StatelessWidget {
  const AlertsNotificationsSection({super.key, required this.alerts});

  final List<OvertimeAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header — stays put; only the content below scrolls.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('alerts_header_title'.tr(), style: TextStyle(fontSize: (22 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('alerts_mark_all_read'.tr(), style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          ],
        ),
        SizedBox(height: 20.h),

        Expanded(
          child: alerts.isEmpty
              ? Center(child: Text('alerts_empty'.tr(), style: TextStyle(fontSize: (13 * scale).sp, color: Colors.grey.shade500)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final alert in alerts) ...[
                        _buildAlertCard(
                          scale: scale,
                          title: 'alerts_overtime_title'.tr(namedArgs: {'name': alert.kidName}),
                          description: 'alerts_overtime_desc'.tr(namedArgs: {'hours': alert.overtimeHours.toStringAsFixed(1)}),
                          borderColor: AppColors.brownLight,
                          icon: Icons.warning_amber_rounded,
                          actions: Row(
                            children: [
                              _buildActionButton('alerts_call_parent'.tr(), scale, isPrimary: true),
                              SizedBox(width: 12.w),
                              _buildActionButton('alerts_extend_session'.tr(), scale, isPrimary: false),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required double scale,
    required String title,
    required String description,
    required Color borderColor,
    required IconData icon,
    Widget? actions,
    String? time,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
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
                    Icon(icon, color: borderColor, size: (24 * scale).w),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(title, style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                              Text('alerts_urgent_badge'.tr(), style: TextStyle(fontSize: (10 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.brownLight, letterSpacing: 1)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(description, style: TextStyle(fontSize: (13 * scale).sp, color: Colors.grey.shade600, height: 1.5)),

                          if (actions != null) ...[
                            SizedBox(height: 16.h),
                            actions,
                          ],
                          if (time != null) ...[
                            SizedBox(height: 16.h),
                            Text(time, style: TextStyle(fontSize: (10 * scale).sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
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

  Widget _buildActionButton(String text, double scale, {required bool isPrimary}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.brown : Colors.transparent, // بني أو شفاف
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.brown, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h * scale),
      ),
      child: Text(text, style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : AppColors.brown)),
    );
  }
}
