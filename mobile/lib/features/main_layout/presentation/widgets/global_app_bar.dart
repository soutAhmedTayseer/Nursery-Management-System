import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../plans/presentation/screens/plans_screen.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkGreen),
      actions: [
        IconButton(
          icon: Icon(Icons.card_membership, color: AppColors.darkGreen, size: 26.w),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlansScreen())
            );
          },
        ),

        IconButton(
          icon: Icon(Icons.person_outline, color: AppColors.darkGreen, size: 28.w),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}