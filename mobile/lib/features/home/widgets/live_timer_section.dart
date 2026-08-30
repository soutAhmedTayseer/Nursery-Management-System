import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class LiveTimerSection extends StatelessWidget {
  const LiveTimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 250.w,
          height: 250.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkGreen, width: 6.w),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LIVE SESSION DURATION',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '02:15:45',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 30.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.lightGreen.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Currently at Wildwood Nursery',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: const BoxDecoration(
            color: AppColors.lightOrange,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.videocam_outlined, color: AppColors.darkGreen, size: 24.w),
        ),
      ],
    );
  }
}