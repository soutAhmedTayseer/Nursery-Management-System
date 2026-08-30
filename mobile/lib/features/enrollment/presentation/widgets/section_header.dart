import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color bgColor;
  final Color iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor, size: 24.w),
          ),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}