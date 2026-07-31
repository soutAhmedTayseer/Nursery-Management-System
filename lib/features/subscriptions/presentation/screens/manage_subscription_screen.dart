import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../widgets/assign_plan_section.dart';
import '../widgets/global_plan_card.dart';
import '../widgets/plan_history_section.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  final KidSession childData;

  const ManageSubscriptionScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('subscriptions_admin_appbar_title'.tr(), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxWidth < 800; 

          return SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Text('subscriptions_manage_title'.tr(), style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                Text('subscriptions_manage_subtitle'.tr(), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                SizedBox(height: 48.h),

                // 2. Global Plans (Horizontal Scroll)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined, color: Colors.brown.shade700, size: 20.w),
                        SizedBox(width: 8.w),
                        Text('subscriptions_global_plans_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12.r)),
                      child: Text('subscriptions_active_plans_badge'.tr(), style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      GlobalPlanCard(title: 'subscriptions_plan_monthly'.tr(), duration: 'subscriptions_plan_monthly_duration'.tr(), price: '\$240', icon: Icons.calendar_month, themeColor: Colors.green),
                      SizedBox(width: 16.w),
                      GlobalPlanCard(title: 'subscriptions_plan_weekly_focus'.tr(), duration: 'subscriptions_plan_weekly_duration'.tr(), price: '\$450', icon: Icons.calendar_today, themeColor: Colors.brown),
                      SizedBox(width: 16.w),
                      GlobalPlanCard(title: 'subscriptions_plan_hourly'.tr(), duration: 'subscriptions_plan_hourly_duration'.tr(), price: '\$18', icon: Icons.access_time, themeColor: Colors.orange),
                      SizedBox(width: 16.w),
                      GlobalPlanCard(title: 'subscriptions_plan_winter_camp'.tr(), duration: 'subscriptions_plan_winter_duration'.tr(), price: '\$1,200', icon: Icons.holiday_village, themeColor: AppColors.forestGreen, isSolid: true),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),

                // 3. Split Layout (Assign Plan & History)
                if (isPortrait) ...[
                  AssignPlanSection(child: childData),
                  SizedBox(height: 32.h),
                  PlanHistorySection(childName: childData.kid.fullName),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: AssignPlanSection(child: childData)),
                      SizedBox(width: 32.w),
                      Expanded(flex: 4, child: PlanHistorySection(childName: childData.kid.fullName)),
                    ],
                  ),
                ],
              ],
            ),
          );
        }
      ),
    );
  }
}
