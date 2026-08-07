import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool iconOnly;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // A green wash reads as "selected" on the light theme's cream sidebar,
    // but the same pale green sitting on a dark sidebar looks like a stray
    // light box rather than a selection state. Dark falls back to a neutral
    // chip fill with the ordinary text colour instead.
    final selectedBg = palette.isDark ? palette.chip : AppColors.sidebarSelectedLight;
    final selectedFg = palette.isDark ? palette.textPrimary : AppColors.darkGreen;
    final iconWidget = Icon(
      icon,
      color: isSelected ? selectedFg : palette.textSecondary,
      size: 22.w
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: iconOnly
            ? Center(child: Tooltip(message: title, child: iconWidget))
            : Row(
                children: [
                  iconWidget,
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? selectedFg : palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
