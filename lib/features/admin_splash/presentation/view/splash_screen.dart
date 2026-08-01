import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/responsive_value.dart';
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
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = const ResponsiveValue<double>(compact: 220, medium: 320, expanded: 420).resolve(context);

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
