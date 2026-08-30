import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class LiveUpdatesSection extends StatelessWidget {
  const LiveUpdatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3ED),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Updates',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Timeline Item 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(radius: 16.r, backgroundColor: AppColors.darkGreen, child: Icon(Icons.palette_outlined, color: Colors.white, size: 16.w)),
                  Container(width: 1.w, height: 100.h, color: Colors.grey.shade300),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT ACTIVITY', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                    SizedBox(height: 4.h),
                    Text('Sensory Play', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4.h),
                    Text('Water, Sand, Dough exploration focused on tactile development.', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.5)),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(width: 80.w, height: 80.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)), child: Center(child: Icon(Icons.image, color: Colors.grey.shade300))),
                        SizedBox(width: 12.w),
                        Container(width: 80.w, height: 80.w, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16.r)), child: Center(child: Icon(Icons.photo_library_outlined, color: AppColors.textPrimary))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Timeline Item 2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 16.r, backgroundColor: Colors.grey.shade200, child: Icon(Icons.restaurant, color: Colors.grey, size: 16.w)),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('11:30 AM', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
                    SizedBox(height: 4.h),
                    Text('Morning Snack', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    SizedBox(height: 4.h),
                    Text('Organic sliced pears and yogurt.', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}