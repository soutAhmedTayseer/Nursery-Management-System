import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class DailyPlanTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;

  const DailyPlanTile({super.key, required this.icon, required this.title, required this.subtitle, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white, // تم تغيير اللون ليتطابق مع الكروت الشهرية
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // نفس الـ Shadow بتاع الشهرية
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.green.shade100,
            child: Icon(icon, color: AppColors.darkGreen, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text(' AED', style: TextStyle(fontSize: 10.sp, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF386A41),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              elevation: 0,
            ),
            child: Text('Select Plan', style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}