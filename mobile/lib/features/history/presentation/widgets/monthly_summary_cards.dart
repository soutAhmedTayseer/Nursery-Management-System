import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class MonthlySummaryCards extends StatelessWidget {
  const MonthlySummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Monthly Total Card (Green)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFC8F6C2), // درجة الأخضر من الصورة
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.access_time, color: AppColors.darkGreen, size: 24.w),
                SizedBox(height: 12.h),
                Text('84h', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                Text('Monthly Total', style: TextStyle(fontSize: 12.sp, color: AppColors.darkGreen, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Overtime Card (Orange)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBCF), // درجة البرتقالي/الخوخي من الصورة
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: const Color(0xFFBF360C), size: 24.w),
                SizedBox(height: 12.h),
                Text('+4h', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: const Color(0xFFBF360C))),
                Text('Overtime', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFBF360C), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}