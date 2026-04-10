import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../widgets/emergency_contact_section.dart';
import '../widgets/registration_form_section.dart';
import '../widgets/registration_input_field.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBF8), // Very light background color
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Text(
                'Complete Registration Form', 
                style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2D2D2D), letterSpacing: -0.5)
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter the comprehensive details for the new enrollment. Please ensure all\ncontact information is accurate for emergency protocols.', 
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500, height: 1.5)
              ),
              SizedBox(height: 48.h),

              // 2. The 3 Columns Layout (Tablet Responsive)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Column 1: Child & Enrollment ---
                  Expanded(
                    child: RegistrationFormSection(
                      title: 'Child &\nEnrollment',
                      icon: Icons.face_retouching_natural,
                      accentColor: const Color(0xFF4A7A3A), // Green
                      children: [
                        const RegistrationInputField(label: 'Child\'s Name in Full', hint: 'Full legal name'),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: RegistrationInputField(label: 'Date of Birth', hint: 'mm/dd/yyyy')),
                            SizedBox(width: 16.w),
                            const Expanded(child: RegistrationInputField(label: 'Date of Enrol', hint: 'mm/dd/yyyy')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: RegistrationInputField(label: 'Timing From', hint: '--:--')),
                            SizedBox(width: 16.w),
                            const Expanded(child: RegistrationInputField(label: 'Timing To', hint: '--:--')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: RegistrationInputField(label: 'Fees (£)', hint: '0.00')),
                            SizedBox(width: 16.w),
                            const Expanded(child: RegistrationInputField(label: 'Number of Hours', hint: 'Weekly')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Allergies / Special Req.', hint: 'List any medical requirements...', maxLines: 3),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: RegistrationInputField(label: 'Nationality', hint: 'Nationality')),
                            SizedBox(width: 16.w),
                            const Expanded(child: RegistrationInputField(label: 'Religion', hint: 'Religion')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Home Address', hint: 'Full residential address'),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),

                  // --- Column 2: Mother's Details ---
                  Expanded(
                    child: RegistrationFormSection(
                      title: 'Mother\'s\nDetails',
                      icon: Icons.female_rounded,
                      accentColor: const Color(0xFF986847), // Brown
                      children: [
                        const RegistrationInputField(label: 'Mothers Contact Phone', hint: '+XX XXXXX XXXXX'),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Contact Email', hint: 'email@example.com'),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: RegistrationInputField(label: 'Occupation', hint: 'Occupation')),
                            SizedBox(width: 16.w),
                            const Expanded(child: RegistrationInputField(label: 'Job Title', hint: 'Job Title')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Company Name', hint: 'Company Name'),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Work Phone', hint: 'Work Phone'),
                        SizedBox(height: 24.h),
                        const RegistrationInputField(label: 'Address', hint: 'Workplace or alternate address', maxLines: 3),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),

                  // --- Column 3: Father's Details & Emergency ---
                  Expanded(
                    child: Column(
                      children: [
                        RegistrationFormSection(
                          title: 'Father\'s\nDetails',
                          icon: Icons.male_rounded,
                          accentColor: const Color(0xFF5D5D5D), // Dark grey
                          children: [
                            const RegistrationInputField(label: 'Fathers Contact Phone', hint: '+XX XXXXX XXXXX'),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                const Expanded(child: RegistrationInputField(label: 'Occupation', hint: 'Occupation')),
                                SizedBox(width: 16.w),
                                const Expanded(child: RegistrationInputField(label: 'Job Title', hint: 'Job Title')),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            const RegistrationInputField(label: 'Contact Email', hint: 'email@example.com'),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                const Expanded(child: RegistrationInputField(label: 'Company', hint: 'Company')),
                                SizedBox(width: 16.w),
                                const Expanded(child: RegistrationInputField(label: 'Work Phone', hint: 'Work Phone')),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            const RegistrationInputField(label: 'Address', hint: 'Workplace address'),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        
                        // Emergency Section
                        EmergencyContactSection(
                          children: [
                            const RegistrationInputField(label: 'Name Relationship', hint: 'e.g. Grandparent / Neighbor Name', maxLines: 2),
                            SizedBox(height: 24.h),
                            const RegistrationInputField(label: 'Contact Number', hint: 'Immediate priority number', maxLines: 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 64.h),

              // 3. Footer Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('CANCEL', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.5)),
                  ),
                  SizedBox(width: 32.w),
                  
                  // Save Button
                  BlocBuilder<RegistrationCubit, RegistrationState>(
                    builder: (context, state) {
                      bool isLoading = state is RegistrationLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => context.read<RegistrationCubit>().registerChild(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF80B674), // Bright green button
                          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                          elevation: 0,
                        ),
                        child: isLoading 
                          ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save & Register Child', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
