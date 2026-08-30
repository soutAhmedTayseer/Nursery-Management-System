import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class MonthlyPlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final bool isPopular;

  const MonthlyPlanCard({
    super.key, required this.title, required this.subtitle, required this.price, this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: isPopular ? Border.all(color: Colors.green.shade200, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) ...[
            Align(
              alignment: Alignment.topRight,
              child: Text('MOST POPULAR', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
                  SizedBox(width: 4.w),
                  Text('AED', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppColors.darkGreen : Colors.green.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: Text('Select Plan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}