import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/enrollment_cubit.dart';
import '../cubit/enrollment_state.dart';
import '../widgets/child_info_step.dart';
import '../widgets/parent_info_step.dart';
import '../widgets/emergency_step.dart';

class EnrollmentScreen extends StatelessWidget {
  const EnrollmentScreen({super.key});

  final List<Widget> steps = const [
    ChildInfoStep(),
    ParentInfoStep(parentType: 'Mother', icon: Icons.female),
    ParentInfoStep(parentType: 'Father', icon: Icons.male),
    EmergencyStep(),
  ];

  final List<String> stepTitles = const [
    'CHILD DETAILS',
    'MOTHER DETAILS',
    'FATHER DETAILS',
    'EMERGENCY INFO',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnrollmentCubit(),
      child: BlocBuilder<EnrollmentCubit, EnrollmentState>(
        builder: (context, state) {
          final cubit = context.read<EnrollmentCubit>();
          bool isLastStep = cubit.currentStep == cubit.totalSteps - 1;
          bool isFirstStep = cubit.currentStep == 0;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.darkGreen, size: 24.w),
                onPressed: () {
                  if (!isFirstStep) {
                    cubit.previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                'Registration',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STEP ${cubit.currentStep + 1} OF ${cubit.totalSteps}',
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade700, letterSpacing: 1.5),
                          ),
                          Text(
                            stepTitles[cubit.currentStep],
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      LinearProgressIndicator(
                        value: (cubit.currentStep + 1) / cubit.totalSteps,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                        minHeight: 2.h,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
                    ),
                    child: IndexedStack(
                      index: cubit.currentStep,
                      children: steps,
                    ),
                  ),
                ),

                Container(
                  color: AppColors.background,
                  padding: EdgeInsets.all(24.w),
                  child: Row(
                    children: [
                      if (!isFirstStep) ...[
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 56.h,
                            child: OutlinedButton(
                              onPressed: () => cubit.previousStep(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              ),
                              child: Text(
                                'BACK',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: 1.2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                      ],

                      // زرار الـ Next أو Submit
                      Expanded(
                        flex: isFirstStep ? 1 : 2,
                        child: SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isLastStep) {
                                Navigator.pop(context);
                              } else {
                                cubit.nextStep();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              isLastStep ? 'SUBMIT' : 'NEXT STEP',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}