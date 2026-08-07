import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../../core/theme/app_palette.dart';

/// Central place for all snackbars — one look everywhere, one place to
/// restyle. Use [AppSnackbar.showSuccess]/[showError] instead of a raw
/// [ScaffoldMessenger] call.
class AppSnackbar {
  const AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.check_circle, color: AppColors.successGreen);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.error, color: AppColors.errorRed);
  }

  static void _show(BuildContext context, {required String message, required IconData icon, required Color color}) {
  final palette = context.palette;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: palette.card,
          elevation: 4,
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: color, size: 22.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: palette.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
