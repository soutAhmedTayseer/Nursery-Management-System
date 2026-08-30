import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/main_layout_cubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدمنا watch عشان الـ Widget ده يعمل Rebuild لما الـ Index يتغير
    final cubit = context.watch<MainLayoutCubit>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
        child: BottomNavigationBar(
          currentIndex: cubit.currentIndex,
          onTap: (index) => cubit.changeIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.darkGreen,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 10.sp,
          unselectedFontSize: 10.sp,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          // أصبحوا 3 عناصر فقط
          items: [
            _buildNavItem(Icons.home_filled, 'Home', 0, cubit.currentIndex),
            _buildNavItem(Icons.history, 'History', 1, cubit.currentIndex),
            _buildNavItem(Icons.receipt_long, 'Billing', 2, cubit.currentIndex),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index, int currentIndex) {
    bool isActive = index == currentIndex;
    return BottomNavigationBarItem(
      icon: Container(
        margin: EdgeInsets.only(bottom: 4.h, top: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 24.w),
      ),
      label: label,
    );
  }
}