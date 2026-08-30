import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../account/presentation/cubit/account_cubit.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../cubit/admin_main_layout_cubit.dart';
import 'sidebar_item.dart';
import '../../../../core/theme/app_palette.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, this.forceFull = false});

  final bool forceFull;

  static const double _fullWidth = 280;
  static const double _railWidth = 72;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.watch<AdminMainLayoutCubit>();
    final showFull = forceFull || context.isExpanded;
    final spacing = AppSpacing.of(context);

    // قائمة الشاشات عشان نولد الأزرار بديناميكية
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard_outlined, 'title': 'sidebar_menu_dashboard'.tr()},
      {'icon': Icons.how_to_reg_outlined, 'title': 'sidebar_menu_registration'.tr()},
      {'icon': Icons.calendar_month_outlined, 'title': 'sidebar_menu_sessions'.tr()},
      {'icon': Icons.card_membership, 'title': 'sidebar_menu_subscriptions'.tr()},
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'sidebar_menu_finance'.tr()},
      {'icon': Icons.settings_outlined, 'title': 'sidebar_menu_settings'.tr()},
    ];

    return Container(
      width: showFull ? _fullWidth : _railWidth,
      color: palette.card,
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          showFull
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.darkGreen,
                      child: Icon(Icons.eco, color: Colors.white, size: 20.w),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('sidebar_brand_name'.tr(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.brandText)),
                          Text('sidebar_brand_subtitle'.tr(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.sp, color: palette.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                )
              : CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.darkGreen,
                  child: Icon(Icons.eco, color: Colors.white, size: 20.w),
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
                    iconOnly: !showFull,
                  ),
                );
              },
            ),
          ),

          // Signed-in identity
          _SidebarIdentity(showFull: showFull),
          SizedBox(height: 12.h),

          // Bottom Actions (Support, Logout)
          _buildBottomAction(context, Icons.help_outline, 'sidebar_support'.tr(), iconOnly: !showFull),
          SizedBox(height: 12.h),
          _buildBottomAction(context, 
            Icons.logout,
            'sidebar_logout'.tr(),
            onTap: () => _handleLogout(context),
            iconOnly: !showFull,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool iconOnly = false}) {

  final palette = context.palette;
    final iconWidget = Icon(icon, color: palette.textSecondary, size: 20.w);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: iconOnly
            ? Center(child: Tooltip(message: title, child: iconWidget))
            : Row(
                children: [
                  iconWidget,
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, color: palette.textSecondary, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SidebarIdentity extends StatelessWidget {
  const _SidebarIdentity({required this.showFull});

  final bool showFull;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountCubit>().state;
    if (state is! AccountLoaded) return const SizedBox.shrink();

    final palette = context.palette;
    final account = state.account;
    final trimmedName = account.fullName.trim();
    final initial = trimmedName.isEmpty ? '?' : trimmedName.substring(0, 1).toUpperCase();

    final avatar = CircleAvatar(
      radius: 16.r,
      backgroundColor: AppColors.darkGreen,
      child: Text(
        initial,
        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
      ),
    );

    if (!showFull) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Center(
          child: Tooltip(message: '${account.fullName} · ${account.role}', child: avatar),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          avatar,
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: palette.textPrimary),
                ),
                Text(
                  account.role,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
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
  if (context.mounted) context.read<AccountCubit>().reset();
  try {
    await sl<AuthRepository>().logout();
  } catch (_) {
    // Fail closed: force re-login rather than leave a stale token behind.
  }
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.adminLogin,
      (route) => false,
    );
  }
}
