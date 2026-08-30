import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'enrollment_text_field.dart';
import 'section_header.dart';

class ChildInfoStep extends StatelessWidget {
  const ChildInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      children: [
        SectionHeader(icon: Icons.face, title: 'Child Info', bgColor: Colors.green.shade100, iconColor: Colors.green.shade800),
        const EnrollmentTextField(label: 'Childs Name In Full', hintText: 'Leo Alexander Woods'),
        Row(
          children: [
            const Expanded(child: EnrollmentTextField(label: 'Date of Birth', hintText: 'mm/dd/yyyy')),
            SizedBox(width: 16.w),
            const Expanded(child: EnrollmentTextField(label: 'Nationality', hintText: 'British')),
          ],
        ),
        const EnrollmentTextField(
          label: 'Allergies',
          hintText: 'None known. Please list food or environmental sensitivities...',
          isHighlight: true,
        ),
        const EnrollmentTextField(label: 'Religion', hintText: 'Optional'),
        const EnrollmentTextField(label: 'Home Address', hintText: 'Full residential address'),
      ],
    );
  }
}