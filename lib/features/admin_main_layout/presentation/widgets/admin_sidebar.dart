import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../cubit/admin_main_layout_cubit.dart';
import 'sidebar_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AdminMainLayoutCubit>();

    // قائمة الشاشات عشان نولد الأزرار بديناميكية
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard_outlined, 'title': 'sidebar_menu_dashboard'.tr()},
      {'icon': Icons.how_to_reg_outlined, 'title': 'sidebar_menu_registration'.tr()},
      {'icon': Icons.calendar_month_outlined, 'title': 'sidebar_menu_sessions'.tr()},
      {'icon': Icons.card_membership, 'title': 'sidebar_menu_subscriptions'.tr()},
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'sidebar_menu_finance'.tr()},
      {'icon': Icons.people_outline, 'title': 'sidebar_menu_profiles'.tr()},
      {'icon': Icons.settings_outlined, 'title': 'sidebar_menu_settings'.tr()},
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
                  Text('sidebar_brand_name'.tr(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('sidebar_brand_subtitle'.tr(), style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
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
          _buildBottomAction(Icons.help_outline, 'sidebar_support'.tr()),
          SizedBox(height: 12.h),
          _buildBottomAction(
            Icons.logout,
            'sidebar_logout'.tr(),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
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

Future<void> _handleLogout(BuildContext context) async {
  final confirmed = await ConfirmationDialog.show(
    context,
    title: 'sidebar_logout_confirm_title'.tr(),
    message: 'sidebar_logout_confirm_message'.tr(),
    confirmLabel: 'sidebar_logout'.tr(),
  );
  if (!confirmed) return;
  await sl<AuthRepository>().logout();
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.adminLogin,
      (route) => false,
    );
  }
}
