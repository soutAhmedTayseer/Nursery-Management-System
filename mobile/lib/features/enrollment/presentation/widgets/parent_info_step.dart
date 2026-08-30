import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'enrollment_text_field.dart';
import 'section_header.dart';

class ParentInfoStep extends StatelessWidget {
  final String parentType;
  final IconData icon;

  const ParentInfoStep({super.key, required this.parentType, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      children: [
        SectionHeader(icon: icon, title: '$parentType Details', bgColor: Colors.orange.shade100, iconColor: Colors.orange.shade800),
        EnrollmentTextField(label: "${parentType}'s Contact Phone", hintText: '+44 7700 900000'),
        const EnrollmentTextField(label: 'Contact Email', hintText: 'example@email.com'),
        const EnrollmentTextField(label: 'Occupation', hintText: 'Software Engineer'),
        const EnrollmentTextField(label: 'Job Title', hintText: 'Senior Developer'),
        const EnrollmentTextField(label: 'Company Name', hintText: 'TechSolutions Ltd'),
        const EnrollmentTextField(label: 'Work Phone', hintText: '+44 20 7946 0000'),
        const EnrollmentTextField(label: 'Address', hintText: 'Office Location'),
      ],
    );
  }
}