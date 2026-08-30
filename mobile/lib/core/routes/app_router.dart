import 'package:flutter/material.dart';
import 'package:nursery_parents_system/features/profile/presentation/screens/profile_screen.dart';
import '../../features/enrollment/presentation/screens/enroll_child_screen.dart';
import '../../features/login/login_screen.dart';
import '../../features/main_layout/main_layout_screen.dart';
import '../../features/register/register_screen.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/view/splash_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.mainLayout:
        return MaterialPageRoute(builder: (_) => const MainLayoutScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.enrollChild:
        return MaterialPageRoute(builder: (_) => const EnrollmentScreen());
      default:
        return null;
    }
  }
}
