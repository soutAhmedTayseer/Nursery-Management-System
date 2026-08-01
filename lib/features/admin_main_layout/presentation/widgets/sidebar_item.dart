import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

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
    final iconWidget = Icon(
      icon,
      color: isSelected ? AppColors.darkGreen : Colors.grey.shade600,
      size: 22.w
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent, // لون الخلفية عند الاختيار
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
                        color: isSelected ? AppColors.darkGreen : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
