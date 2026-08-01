import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final Widget bottomWidget;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Title & Icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.w800, color: themeColor, letterSpacing: 1.5),
              ),
              CircleAvatar(
                radius: (18 * scale).r,
                backgroundColor: themeColor,
                child: Icon(icon, color: Colors.white, size: (18 * scale).w),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Value & Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: (48 * scale).sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1)),
              if (unit != null) ...[
                SizedBox(width: 8.w),
                Text(unit!, style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
              ]
            ],
          ),
          SizedBox(height: 8.h),
          Text(subtitle, style: TextStyle(fontSize: (14 * scale).sp, color: Colors.grey.shade500)),

          SizedBox(height: 24.h),
          // Dynamic Bottom Section
          bottomWidget,
        ],
      ),
    );
  }
}
