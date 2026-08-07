import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/l10n/api_error_messages.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/admin_login_cubit.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/login_background_decor.dart';
import '../../../../core/theme/app_palette.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spacing = AppSpacing.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidthFraction = const ResponsiveValue<double>(
      compact: 0.9,
      medium: 0.75,
      expanded: 0.6,
    ).resolve(context);
    final finalCardWidth = (screenWidth * cardWidthFraction).clamp(420.0, 850.0);

    return BlocProvider(
      create: (_) => sl<AdminLoginCubit>(),
      child: BlocListener<AdminLoginCubit, AdminLoginState>(
        listener: (context, state) {
          if (state is AdminLoginSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminMainLayout);
          } else if (state is AdminLoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(apiErrorMessage(state.exception))),
            );
          }
        },
        child: Scaffold(
          backgroundColor: palette.page,
          body: Stack(
            children: [
              const LoginBackgroundDecor(),

              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section (أكبر وأوضح)
                      Icon(Icons.park, color: palette.brandText, size: 70.w),
                      SizedBox(height: 16.h),
                      Text(
                        'login_logo_title'.tr(),
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: palette.brandText, letterSpacing: 1.5),
                      ),
                      Text(
                        'login_portal_subtitle'.tr(),
                        style: TextStyle(fontSize: 14.sp, color: palette.textTertiary, fontWeight: FontWeight.w600, letterSpacing: 6),
                      ),
                      SizedBox(height: 50.h),

                      // 2. Login Card (تم حل مشكلة الـ Constraints)
                      Container(
                        width: finalCardWidth, // تحديد العرض المباشر يمنع الـ Non-normalized Error
                        padding: EdgeInsets.symmetric(horizontal: spacing.xxl, vertical: spacing.xxl),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(40.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 50,
                                offset: const Offset(0, 20)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                'login_welcome_back'.tr(),
                                style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.w900, color: palette.textPrimary)
                            ),
                            SizedBox(height: 16.h),
                            Text(
                                'login_instructions'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.sp, color: palette.textTertiary, height: 1.6)
                            ),
                            SizedBox(height: 64.h),

                            // Form Fields
                            AdminTextField(
                              label: 'login_email_hint'.tr(),
                              hint: 'admin@wildwood.com',
                              suffixIcon: Icons.person_outline,
                              controller: _emailController,
                            ),
                            SizedBox(height: 32.h),
                            AdminTextField(
                              label: 'login_password_hint'.tr(),
                              hint: '•••• ••••',
                              suffixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
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
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            final email = _emailController.text.trim();
                                            final password = _passwordController.text;
                                            if (email.isEmpty || password.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('login_error_empty_fields'.tr())),
                                              );
                                              return;
                                            }
                                            context.read<AdminLoginCubit>().login(email, password);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(width: 28.w, height: 28.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                        : Text('login_submit_button'.tr(), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: palette.card, letterSpacing: 2.5)),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32.h),

                            TextButton(
                              // No password-reset endpoint exists yet, so
                              // point the admin at the desk that can do it
                              // manually instead of leaving a dead button.
                              onPressed: () => AppSnackbar.showSuccess(
                                context,
                                'login_forgot_password_hint'.tr(),
                              ),
                              child: Text(
                                'login_forgot_password'.tr(),
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.brownDark),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 64.h),
                      Text(
                        'login_footer'.tr(),
                        style: TextStyle(fontSize: 14.sp, color: palette.textTertiary, fontWeight: FontWeight.w500, letterSpacing: 1.5),
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
