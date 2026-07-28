import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmergencyContactSection extends StatelessWidget {
  final List<Widget> children;

  const EmergencyContactSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EC),
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
                color: const Color(0xFFC72424),
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
                          radius: 18.r,
                          backgroundColor: const Color(0xFFC72424).withOpacity(0.1),
                          child: Icon(Icons.medical_services_rounded, color: const Color(0xFFC72424), size: 18.w),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'emergency_contact_title'.tr(),
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFFC72424), letterSpacing: 1.2, height: 1.2),
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
