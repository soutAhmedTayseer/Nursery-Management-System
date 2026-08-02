import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';

/// Final registration step: the nursery's terms & conditions in a scrollable
/// box, followed by [children] (allergy recap, media release choice,
/// signature, date) — matches the other step sections' card styling.
class AgreementSection extends StatelessWidget {
  const AgreementSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: (18 * scale).r,
                backgroundColor: AppColors.darkGreen.withValues(alpha: 0.1),
                child: Icon(
                  Icons.description_outlined,
                  color: AppColors.darkGreen,
                  size: (18 * scale).w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  'registration_section_agreement'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: (16 * scale).sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreen,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            height: 320.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Text(
                  'registration_agreement_terms'.tr(),
                  style: TextStyle(
                    fontSize: (12.5 * scale).sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ...children,
        ],
      ),
    );
  }
}
