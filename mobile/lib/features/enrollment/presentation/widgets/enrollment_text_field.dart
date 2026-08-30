import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class EnrollmentTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isHighlight;

  const EnrollmentTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.red.shade400 : AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            maxLines: isHighlight ? 3 : 1,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: isHighlight ? Colors.red.shade300 : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: isHighlight ? Colors.red.shade400 : AppColors.darkGreen,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}