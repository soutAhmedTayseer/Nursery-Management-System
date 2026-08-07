import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../../core/theme/app_palette.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary.withValues(alpha: 0.7),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          style: TextStyle(fontSize: 16.sp, color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: palette.textTertiary, fontSize: 16.sp),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.lightGrey,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: palette.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
