import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_parents_system/features/login/presentation/cubit/login_cubit.dart';
import 'package:nursery_parents_system/features/login/presentation/cubit/login_state.dart';
import 'package:nursery_parents_system/core/widgets/custom_text_field.dart';
import 'package:nursery_parents_system/core/widgets/social_auth_button.dart'; // Import for Google Button
import 'package:nursery_parents_system/core/routes/app_routes.dart'; // Import for Routing
import '../../../../core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  // Logo Section
                  Icon(Icons.park, size: 48.w, color: AppColors.primaryGreen), // Placeholder for Tree icon
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
                  SizedBox(height: 40.h),

                  // Login Card
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
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Manage your child\'s journey through the wild',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Inputs
                        const CustomTextField(
                          label: 'Email or Phone Number',
                          hintText: 'name@domain.com',
                        ),
                        SizedBox(height: 20.h),

                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final cubit = context.read<LoginCubit>();
                            return CustomTextField(
                              label: 'Password',
                              hintText: '••••••••',
                              isObscure: cubit.isPasswordObscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  cubit.isPasswordObscure ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                  size: 20.w,
                                ),
                                onPressed: () => cubit.togglePasswordVisibility(),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 32.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.mainLayout);

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Forgot Password
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.brownLink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        SocialAuthButton(onPressed: () {}),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Bottom Section
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'NEW HERE?',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: () {
                      // الانتقال لشاشة الـ Register
                      Navigator.pushReplacementNamed(context, AppRoutes.register);
                    },
                    child: Text(
                      'Join the Wilderness Family',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
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