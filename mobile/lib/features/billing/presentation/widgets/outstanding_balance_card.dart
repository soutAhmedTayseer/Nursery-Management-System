import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class OutstandingBalanceCard extends StatelessWidget {
  const OutstandingBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B9B64), Color(0xFFA5D6A7)], // التدرج الأخضر من الديزاين
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL OUTSTANDING BALANCE',
            style: TextStyle(fontSize: 10.sp, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '70',
                style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Text(
                'AED',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                elevation: 0,
              ),
              icon: Icon(Icons.payments_outlined, color: AppColors.darkGreen, size: 20.w),
              label: Text(
                'Pay Now',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}