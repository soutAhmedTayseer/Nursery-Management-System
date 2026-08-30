import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class ExtraHoursLogContent extends StatelessWidget {
  const ExtraHoursLogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Log Item
        Row(
          children: [
            // Date Badge
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('OCT', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  Text('12', style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('2h Overtime', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(width: 4.w),
                      Icon(Icons.info, color: Colors.orange.shade700, size: 14.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text('Calculation: 2h x 35 AED', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                ],
              ),
            ),
            // Price & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('70', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                Text('AED', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                SizedBox(height: 2.h),
                Text('Pending', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Info Banner
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3ED),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Overtime is calculated at 35 AED per hour or part thereof after the scheduled pickup time.',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}