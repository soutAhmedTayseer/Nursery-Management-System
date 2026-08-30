import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/billing_cubit.dart';

class BillingHeaderSelector extends StatelessWidget {
  const BillingHeaderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدمنا watch هنا عشان الـ Widget ده يتحدث تلقائياً لما نغير الطفل
    final cubit = context.watch<BillingCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. الجزء الأيسر: النصوص
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing for',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              cubit.selectedChild['name'] ?? '',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24.sp, // كبرنا الخط شوية لأنه بقى في جسم الشاشة
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // 2. الجزء الأيمن: صورة الطفل والـ Dropdown
        PopupMenuButton<Map<String, String>>(
          offset: const Offset(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          color: Colors.white,
          elevation: 4,
          onSelected: (selectedChild) => cubit.changeChild(selectedChild),
          itemBuilder: (context) {
            return cubit.childrenList.map((child) {
              return PopupMenuItem<Map<String, String>>(
                value: child,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundImage: AssetImage(child['image'] ?? ''),
                      backgroundColor: Colors.green.shade50,
                      onBackgroundImageError: (_, __) {},
                      child: child['image'] == null || child['image']!.isEmpty
                          ? Icon(Icons.face, size: 20.w, color: AppColors.darkGreen)
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      child['name'] ?? '',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          // الصورة الأساسية اللي بنضغط عليها
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade100, width: 2), // إطار خفيف شيك
            ),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.green.shade50,
              backgroundImage: AssetImage(cubit.selectedChild['image'] ?? ''),
              onBackgroundImageError: (_, __) {},
              child: cubit.selectedChild['image'] == null || cubit.selectedChild['image']!.isEmpty
                  ? Icon(Icons.face, size: 28.w, color: AppColors.darkGreen)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}