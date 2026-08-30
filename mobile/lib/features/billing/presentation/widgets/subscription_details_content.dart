import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class SubscriptionDetailsContent extends StatelessWidget {
  const SubscriptionDetailsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3ED), // اللون الرمادي الفاتح
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.darkGreen, width: 4.w)), // الخط الأخضر عالشمال
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Winter Camp', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.green.shade200, borderRadius: BorderRadius.circular(8.r)),
                    child: Text('ACTIVE', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text('5h / 5 Days per week', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Next Renewal', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  Text('Nov 01, 2023', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}