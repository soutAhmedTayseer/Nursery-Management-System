import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_parents_system/features/register/presentation/cubit/register_cubit.dart';
import 'package:nursery_parents_system/features/register/presentation/cubit/register_state.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../core/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Icon(Icons.park, size: 48.w, color: AppColors.primaryGreen),
                  SizedBox(height: 8.h),
                  Text(
                    'WILDERNESS NURSERY',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 30.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(28.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        const CustomTextField(label: 'Full Name', hintText: 'John Doe'),
                        SizedBox(height: 16.h),
                        const CustomTextField(label: 'Email or Phone', hintText: 'name@domain.com'),
                        SizedBox(height: 16.h),

                        BlocBuilder<RegisterCubit, RegisterState>(
                          builder: (context, state) {
                            final cubit = context.read<RegisterCubit>();
                            return Column(
                              children: [
                                CustomTextField(
                                  label: 'Password',
                                  hintText: '••••••••',
                                  isObscure: cubit.isPasswordObscure,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      cubit.isPasswordObscure ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey, size: 20.w,
                                    ),
                                    onPressed: () => cubit.togglePasswordVisibility(),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                CustomTextField(
                                  label: 'Confirm Password',
                                  hintText: '••••••••',
                                  isObscure: cubit.isConfirmPasswordObscure,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      cubit.isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey, size: 20.w,
                                    ),
                                    onPressed: () => cubit.toggleConfirmPasswordVisibility(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              'REGISTER',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // زرار جوجل
                        SocialAuthButton(onPressed: () {}),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text('ALREADY A MEMBER?', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Text(
                      'Login to your account',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}