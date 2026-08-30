import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class SpecialOfferCard extends StatelessWidget {
  final String badgeText;
  final String title;
  final String price;
  final Color bgColor;
  final IconData bgIcon;

  const SpecialOfferCard({
    super.key,
    required this.badgeText,
    required this.title,
    required this.price,
    required this.bgColor,
    required this.bgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w, // تم زيادة العرض لـ 260 بدلاً من 220
      height: 190.h, // تم زيادة الطول لـ 190 بدلاً من 140 لحل الـ Overflow
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Stack(
        children: [
          // الأيقونة المائية في الخلفية
          Positioned(
            top: 10.h,
            right: -10.w,
            child: Icon(bgIcon, size: 110.w, color: Colors.white.withOpacity(0.3)),
          ),

          // المحتوى الأساسي
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r)
                  ),
                  child: Text(badgeText, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),

                const Spacer(), // Spacer دلوقتي واخد راحته تماماً بعد زيادة الطول

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        minimumSize: Size(70.w, 36.h),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Text('SELECT', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}