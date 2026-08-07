import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class EmergencyContactSection extends StatelessWidget {
  final List<Widget> children;

  const EmergencyContactSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.sand,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Side red line
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), bottomLeft: Radius.circular(32.r)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: (18 * scale).r,
                          backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
                          child: Icon(Icons.medical_services_rounded, color: palette.dangerText, size: (18 * scale).w),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'emergency_contact_title'.tr(),
                            style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.w900, color: palette.dangerText, letterSpacing: 1.2, height: 1.2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    ...children,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
