import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Placeholder while this screen is redesigned — subscription management
/// now lives behind sessions cards (see ManageSubscriptionScreen), and
/// this tab will get new content later.
class SubscribedChildrenScreen extends StatelessWidget {
  const SubscribedChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 48.w, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'subscribed_children_coming_soon'.tr(),
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
