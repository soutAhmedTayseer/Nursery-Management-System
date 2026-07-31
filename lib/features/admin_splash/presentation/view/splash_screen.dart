import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..checkSession(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
          } else if (state is SplashNavigateToLayout) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminMainLayout);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/splash.json',
                  width: 240.w,
                  height: 240.w,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}