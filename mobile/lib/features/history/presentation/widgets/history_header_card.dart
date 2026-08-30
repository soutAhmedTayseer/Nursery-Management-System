import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/history_cubit.dart';

class HistoryHeaderCard extends StatelessWidget {
  const HistoryHeaderCard({super.key});

  // دالة لفتح الـ Animated Bottom Sheet لاختيار الشهر
  void _showMonthPicker(BuildContext context, HistoryCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // عشان نقدر نعمل حواف دائرية
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // بياخد مساحة المحتوى بس
            children: [
              Text(
                'Select Month',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 16.h),
              // قائمة الشهور
              ...cubit.months.map((month) {
                bool isSelected = month == cubit.selectedMonth;
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 32.w),
                  title: Text(
                    month,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.darkGreen : AppColors.textPrimary,
                    ),
                  ),
                  // أيقونة صح جنب الشهر المختار حالياً
                  trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.darkGreen, size: 24.w) : null,
                  onTap: () {
                    cubit.changeMonth(month);
                    Navigator.pop(context); // قفل الشيت بعد الاختيار بانيميشن
                  },
                );
              }).toList(),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HistoryCubit>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Month Selector (Custom Animated Trigger)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Viewing records for',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),

              // ده الزرار الجديد اللي هيظهر مكان الـ Dropdown القديم
              GestureDetector(
                onTap: () => _showMonthPicker(context, cubit),
                child: Container(
                  color: Colors.transparent, // ضروري عشان يخلي الـ Row كلها قابلة للضغط
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Text(
                        cubit.selectedMonth,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.darkGreen, size: 20.w),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Child Avatar Selector (PopupMenuButton)
          PopupMenuButton<Map<String, String>>(
            offset: const Offset(0, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            color: Colors.white,
            elevation: 4,
            onSelected: (selectedChild) {
              cubit.changeChild(selectedChild);
            },
            itemBuilder: (context) {
              return cubit.childrenList.map((child) {
                return PopupMenuItem<Map<String, String>>(
                  value: child,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.green.shade50,
                        backgroundImage: AssetImage(child['image'] ?? ''),
                        onBackgroundImageError: (_, __) {},
                        child: child['image'] == null || child['image']!.isEmpty
                            ? Icon(Icons.face, size: 20.w, color: AppColors.darkGreen)
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        child['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade100, width: 2),
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
      ),
    );
  }
}