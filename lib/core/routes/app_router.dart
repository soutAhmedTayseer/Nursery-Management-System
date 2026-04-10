import 'package:flutter/material.dart';
import '../../features/admin_splash/presentation/view/splash_screen.dart';
import '../../features/admin_login/presentation/screens/admin_login_screen.dart';
import '../../features/admin_main_layout/presentation/screens/admin_main_layout_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.adminSplash:
        return MaterialPageRoute(builder: (_) => const AdminSplashScreen());
      case AppRoutes.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case AppRoutes.adminMainLayout:
        return MaterialPageRoute(builder: (_) => const AdminMainLayoutScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
