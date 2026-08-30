import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/active_subscription_card.dart';
import '../../widgets/kid_selector_pill.dart';
import '../../widgets/live_timer_section.dart';
import '../../widgets/live_updates_section.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24.h),
            const KidSelectorPill(),
            SizedBox(height: 32.h),
            const LiveTimerSection(),
            SizedBox(height: 32.h),
            const ActiveSubscriptionCard(),
            SizedBox(height: 24.h),
            const LiveUpdatesSection(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}