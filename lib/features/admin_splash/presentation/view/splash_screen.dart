import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale off the actual screen instead of fixed per-breakpoint tiers — a
    // portrait tablet is still `compact` (width-based breakpoint) despite
    // having plenty of screen height, so a fixed 220px tier read as tiny.
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = (shortestSide * 0.5).clamp(200.0, 420.0);

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
          backgroundColor: AppColors.surfacePage,
          body: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Lottie.asset(
                  'assets/animations/splash.json',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
