import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.surfaceLinen, // Very light background color
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Text(
                'registration_header_title'.tr(),
                style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.w900, color: AppColors.textHeading, letterSpacing: -0.5)
              ),
              SizedBox(height: 8.h),
              Text(
                'registration_header_subtitle'.tr(),
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
                      title: 'registration_section_child'.tr(),
                      icon: Icons.face_retouching_natural,
                      accentColor: AppColors.accentGreen, // Green
                      children: [
                        RegistrationInputField(label: 'registration_label_child_name'.tr(), hint: 'registration_hint_child_name'.tr()),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: RegistrationInputField(label: 'registration_label_dob'.tr(), hint: 'registration_hint_date'.tr())),
                            SizedBox(width: 16.w),
                            Expanded(child: RegistrationInputField(label: 'registration_label_enrol_date'.tr(), hint: 'registration_hint_date'.tr())),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: RegistrationInputField(label: 'registration_label_timing_from'.tr(), hint: 'registration_hint_time'.tr())),
                            SizedBox(width: 16.w),
                            Expanded(child: RegistrationInputField(label: 'registration_label_timing_to'.tr(), hint: 'registration_hint_time'.tr())),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: RegistrationInputField(label: 'registration_label_fees'.tr(), hint: 'registration_hint_fees'.tr())),
                            SizedBox(width: 16.w),
                            Expanded(child: RegistrationInputField(label: 'registration_label_hours'.tr(), hint: 'registration_hint_weekly'.tr())),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_allergies'.tr(), hint: 'registration_hint_allergies'.tr(), maxLines: 3),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: RegistrationInputField(label: 'registration_label_nationality'.tr(), hint: 'registration_hint_nationality'.tr())),
                            SizedBox(width: 16.w),
                            Expanded(child: RegistrationInputField(label: 'registration_label_religion'.tr(), hint: 'registration_hint_religion'.tr())),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_home_address'.tr(), hint: 'registration_hint_home_address'.tr()),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),

                  // --- Column 2: Mother's Details ---
                  Expanded(
                    child: RegistrationFormSection(
                      title: 'registration_section_mother'.tr(),
                      icon: Icons.female_rounded,
                      accentColor: AppColors.bronze, // Brown
                      children: [
                        RegistrationInputField(label: 'registration_label_mother_phone'.tr(), hint: 'registration_hint_phone'.tr()),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_contact_email'.tr(), hint: 'registration_hint_email'.tr()),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: RegistrationInputField(label: 'registration_label_occupation'.tr(), hint: 'registration_hint_occupation'.tr())),
                            SizedBox(width: 16.w),
                            Expanded(child: RegistrationInputField(label: 'registration_label_job_title'.tr(), hint: 'registration_hint_job_title'.tr())),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_company_name'.tr(), hint: 'registration_hint_company_name'.tr()),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_work_phone'.tr(), hint: 'registration_hint_work_phone'.tr()),
                        SizedBox(height: 24.h),
                        RegistrationInputField(label: 'registration_label_address_alt'.tr(), hint: 'registration_hint_workplace_alt'.tr(), maxLines: 3),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),

                  // --- Column 3: Father's Details & Emergency ---
                  Expanded(
                    child: Column(
                      children: [
                        RegistrationFormSection(
                          title: 'registration_section_father'.tr(),
                          icon: Icons.male_rounded,
                          accentColor: AppColors.textSecondary, // Dark grey
                          children: [
                            RegistrationInputField(label: 'registration_label_father_phone'.tr(), hint: 'registration_hint_phone'.tr()),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                Expanded(child: RegistrationInputField(label: 'registration_label_occupation'.tr(), hint: 'registration_hint_occupation'.tr())),
                                SizedBox(width: 16.w),
                                Expanded(child: RegistrationInputField(label: 'registration_label_job_title'.tr(), hint: 'registration_hint_job_title'.tr())),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            RegistrationInputField(label: 'registration_label_contact_email'.tr(), hint: 'registration_hint_email'.tr()),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                Expanded(child: RegistrationInputField(label: 'registration_label_company'.tr(), hint: 'registration_hint_company'.tr())),
                                SizedBox(width: 16.w),
                                Expanded(child: RegistrationInputField(label: 'registration_label_work_phone'.tr(), hint: 'registration_hint_work_phone'.tr())),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            RegistrationInputField(label: 'registration_label_address_alt'.tr(), hint: 'registration_hint_workplace'.tr()),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Emergency Section
                        EmergencyContactSection(
                          children: [
                            RegistrationInputField(label: 'registration_label_name_relationship'.tr(), hint: 'registration_hint_name_relationship'.tr(), maxLines: 2),
                            SizedBox(height: 24.h),
                            RegistrationInputField(label: 'registration_label_contact_number'.tr(), hint: 'registration_hint_contact_number'.tr(), maxLines: 2),
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
                    child: Text('registration_cancel'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.5)),
                  ),
                  SizedBox(width: 32.w),
                  
                  // Save Button
                  BlocBuilder<RegistrationCubit, RegistrationState>(
                    builder: (context, state) {
                      bool isLoading = state is RegistrationLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => context.read<RegistrationCubit>().registerChild(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leafGreen, // Bright green button
                          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                          elevation: 0,
                        ),
                        child: isLoading 
                          ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('registration_save_button'.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
