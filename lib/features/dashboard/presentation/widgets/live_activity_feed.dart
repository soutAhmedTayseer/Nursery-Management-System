import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class LiveActivityFeed extends StatelessWidget {
  const LiveActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('feed_title'.tr(), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                CircleAvatar(radius: 4.r, backgroundColor: Colors.green),
                SizedBox(width: 8.w),
                Text('feed_live_now'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Upcoming Activity Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder (The Girl)
              Container(
                width: 100.w,
                height: 120.h,
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16.r)),
                child: Icon(Icons.child_care, size: 50.w, color: Colors.grey.shade400), // استخدم الصورة الحقيقية هنا
              ),
              SizedBox(width: 20.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('feed_upcoming_activity'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFFB08D5B), letterSpacing: 1.2)),
                    SizedBox(height: 8.h),
                    Text('feed_upcoming_time_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 8.h),
                    Text(
                      'feed_upcoming_desc'.tr(),
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, height: 1.5),
                    ),
                    SizedBox(height: 16.h),
                    // Avatars row
                    Row(
                      children: [
                        _buildOverlapAvatar('assets/images/child_1.png'),
                        _buildOverlapAvatar('assets/images/child_2.png', offset: -10),
                        _buildOverlapAvatar('assets/images/child_3.png', offset: -20),
                        Transform.translate(
                          offset: Offset(-30.w, 0),
                          child: CircleAvatar(radius: 14.r, backgroundColor: Colors.grey.shade200, child: Text('+12', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Past Activity Tile
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(24.r)),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.grey.shade600, size: 20.w),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('feed_past_activity_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 4.h),
                  Text('feed_past_activity_desc'.tr(), style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlapAvatar(String imagePath, {double offset = 0}) {
    return Transform.translate(
      offset: Offset(offset.w, 0),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: CircleAvatar(radius: 14.r, backgroundColor: Colors.green.shade50, backgroundImage: AssetImage(imagePath), onBackgroundImageError: (_,__) {}),
      ),
    );
  }
}