import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class LocationMapCard extends StatelessWidget {
  const LocationMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w), // المسافة الداخلية للكارت الأبيض
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nursery Location', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text('Oakwood Grove, 122 Willow Lane', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                child: Icon(Icons.location_on_outlined, color: AppColors.darkGreen, size: 20.w),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Map Placeholder Container
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade300,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), bottomRight: Radius.circular(24.r)),
                    ),
                    child: Icon(Icons.map_outlined, color: AppColors.darkGreen, size: 24.w),
                  ),
                ),
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                    child: Row(
                      children: [
                        Text('Open in Maps', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(width: 4.w),
                        Icon(Icons.open_in_new, size: 14.w, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}