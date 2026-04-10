import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/admin_login_cubit.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/login_background_decor.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. حسابات العرض بدقة للتابلت
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // جعل الكارت يشغل مساحة معتبرة (70% في الأفقي و 85% في الرأسي)
    // واستخدام clamp لضمان أن العرض يترواح بين 550 و 800 بكسل دائماً
    final double finalCardWidth = (isPortrait ? screenWidth * 0.85 : screenWidth * 0.7)
        .clamp(550.0, 850.0);

    return BlocProvider(
      create: (context) => AdminLoginCubit(),
      child: BlocListener<AdminLoginCubit, AdminLoginState>(
        listener: (context, state) {
          if (state is AdminLoginSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminMainLayout);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          body: Stack(
            children: [
              const LoginBackgroundDecor(),

              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section (أكبر وأوضح)
                      Icon(Icons.park, color: AppColors.darkGreen, size: 70.w),
                      SizedBox(height: 16.h),
                      Text(
                        'Wildwood Nursery',
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: 1.5),
                      ),
                      Text(
                        'ADMINISTRATION PORTAL',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 6),
                      ),
                      SizedBox(height: 50.h),

                      // 2. Login Card (تم حل مشكلة الـ Constraints)
                      Container(
                        width: finalCardWidth, // تحديد العرض المباشر يمنع الـ Non-normalized Error
                        padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 72.h), // Padding ضخم للفخامة
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 50,
                                offset: const Offset(0, 20)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                'Welcome Back',
                                style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)
                            ),
                            SizedBox(height: 16.h),
                            Text(
                                'Please enter your administrator credentials to manage the nursery ecosystem.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade500, height: 1.6)
                            ),
                            SizedBox(height: 64.h),

                            // Form Fields
                            const AdminTextField(
                              label: 'Email or Phone Number',
                              hint: 'admin@wildwood.com',
                              suffixIcon: Icons.person_outline,
                            ),
                            SizedBox(height: 32.h),
                            const AdminTextField(
                              label: 'Password',
                              hint: '•••• ••••',
                              suffixIcon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            SizedBox(height: 64.h),

                            // Login Button (أضخم واحترافي)
                            BlocBuilder<AdminLoginCubit, AdminLoginState>(
                              builder: (context, state) {
                                bool isLoading = state is AdminLoginLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 70.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : () => context.read<AdminLoginCubit>().login(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(width: 28.w, height: 28.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                        : Text('ACCESS PORTAL', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.5)),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32.h),

                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6D4C41)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 64.h),
                      Text(
                        'SECURE SERVER ACCESS. © 2026 WILDWOOD NURSERY MANAGEMENT.',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}