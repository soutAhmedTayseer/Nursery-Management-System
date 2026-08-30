import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkGreen),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1, color: AppColors.darkGreen),
            title: Text(
              'Enroll a Child',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.enrollChild,
              );
            },
          ),

          const Divider(),

          _buildDrawerItem(context, Icons.settings, 'Settings'),
          _buildDrawerItem(context, Icons.notifications, 'Notifications'),
          _buildDrawerItem(context, Icons.help_outline, 'Support'),
          _buildDrawerItem(context, Icons.info_outline, 'About Us'),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Logout', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : AppColors.darkGreen),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(title)),
              body: Center(child: Text('$title Screen Placeholder')),
            ),
          ),
        );
      },
    );
  }
}
