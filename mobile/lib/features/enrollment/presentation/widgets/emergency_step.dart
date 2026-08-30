import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'enrollment_text_field.dart';
import 'section_header.dart';

class EmergencyStep extends StatelessWidget {
  const EmergencyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      children: [
        SectionHeader(icon: Icons.medical_services, title: 'Emergency', bgColor: Colors.green.shade800, iconColor: Colors.white),
        const EnrollmentTextField(label: 'Emergency Name & Relationship', hintText: 'Grandmother - Martha Woods'),
        const EnrollmentTextField(label: 'Emergency Contact Number', hintText: '+44 7700 900222'),

        SizedBox(height: 80.h),
        // Footer Logo
        Center(
          child: Column(
            children: [
              Icon(Icons.eco, color: Colors.grey.shade400, size: 48.w),
              SizedBox(height: 8.h),
              Text(
                  'NATURE-LED REGISTRATION',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey, letterSpacing: 2)
              ),
            ],
          ),
        )
      ],
    );
  }
}