import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/admin_main_layout_cubit.dart';
import 'sidebar_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AdminMainLayoutCubit>();

    // قائمة الشاشات عشان نولد الأزرار بديناميكية
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard_outlined, 'title': 'Dashboard'},
      {'icon': Icons.how_to_reg_outlined, 'title': 'Registration'},
      {'icon': Icons.calendar_month_outlined, 'title': 'Sessions'},
      {'icon': Icons.card_membership, 'title': 'Subscriptions'},
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'Finance'},
      {'icon': Icons.people_outline, 'title': 'Profiles'},
      {'icon': Icons.settings_outlined, 'title': 'Settings'},
    ];

    return Container(
      width: 250.w, // عرض ثابت للـ Sidebar يناسب التابلت
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.darkGreen,
                child: Icon(Icons.eco, color: Colors.white, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wildwood', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('Nursery Admin', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          SizedBox(height: 40.h),

          // Main Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: SidebarItem(
                    icon: menuItems[index]['icon'],
                    title: menuItems[index]['title'],
                    isSelected: cubit.currentIndex == index,
                    onTap: () => cubit.changeScreen(index),
                  ),
                );
              },
            ),
          ),

          // Bottom Actions (Support, Logout)
          SizedBox(height: 16.h),
          _buildBottomAction(Icons.help_outline, 'Support'),
          SizedBox(height: 12.h),
          _buildBottomAction(Icons.logout, 'Logout'),
        ],
      ),
    );
  }

  Widget _buildBottomAction(IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20.w),
            SizedBox(width: 12.w),
            Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
