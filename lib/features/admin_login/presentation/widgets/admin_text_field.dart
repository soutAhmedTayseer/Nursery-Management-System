import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class AdminTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const AdminTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.suffixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14.sp, // تم تكبير الخط (كان 10)
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
            letterSpacing: 1.5, // إضافة مسافة بين الحروف
          ),
        ),
        SizedBox(height: 12.h), // تم تكبير المسافة
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(fontSize: 18.sp, color: palette.textPrimary), // خط الكتابة (كان 14)
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: palette.textTertiary, fontSize: 18.sp), // الـ Hint (كان 14)
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(suffixIcon, color: palette.textTertiary, size: 26.w), // الأيقونة (كانت 20)
            ),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), // تم تكبير الـ Padding الداخلي (كان 16)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}