import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrationInputField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const RegistrationInputField({
    super.key, required this.label, required this.hint, this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp, 
            fontWeight: FontWeight.w800, 
            color: AppColors.textTertiary, // Dark grey for Label
            letterSpacing: 1.1
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          maxLines: maxLines,
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
