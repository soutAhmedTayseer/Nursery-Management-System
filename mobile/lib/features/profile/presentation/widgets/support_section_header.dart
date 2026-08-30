import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class SupportSectionHeader extends StatelessWidget {
  const SupportSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Support & Nursery Info', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(16.r)),
          child: Text('Help Center', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
        ),
      ],
    );
  }
}