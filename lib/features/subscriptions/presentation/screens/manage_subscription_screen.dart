import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../sessions/data/models/child_session_model.dart';
import '../widgets/assign_plan_section.dart';
import '../widgets/global_plan_card.dart';
import '../widgets/plan_history_section.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  final ChildSessionModel childData;

  const ManageSubscriptionScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Admin - Manage Subscriptions (Plans & Assignment)', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
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
                Text('Manage Subscriptions', style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                Text('Configure global nursery plans and assign subscriptions to students.', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                SizedBox(height: 48.h),

                // 2. Global Plans (Horizontal Scroll)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined, color: Colors.brown.shade700, size: 20.w),
                        SizedBox(width: 8.w),
                        Text('Global Subscription Plans', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12.r)),
                      child: Text('4 Active Plans', style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      const GlobalPlanCard(title: 'Monthly', duration: '3 hours / 3 Days', price: '\$240', icon: Icons.calendar_month, themeColor: Colors.green),
                      SizedBox(width: 16.w),
                      const GlobalPlanCard(title: 'Weekly Focus', duration: '5 hours / 5 Days', price: '\$450', icon: Icons.calendar_today, themeColor: Colors.brown),
                      SizedBox(width: 16.w),
                      const GlobalPlanCard(title: 'Hourly', duration: 'Flexible drop-in', price: '\$18', icon: Icons.access_time, themeColor: Colors.orange),
                      SizedBox(width: 16.w),
                      const GlobalPlanCard(title: 'Winter Camp', duration: 'Seasonal Intensive', price: '\$1,200', icon: Icons.holiday_village, themeColor: Color(0xFF386A41), isSolid: true),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),

                // 3. Split Layout (Assign Plan & History)
                if (isPortrait) ...[
                  AssignPlanSection(child: childData),
                  SizedBox(height: 32.h),
                  PlanHistorySection(childName: childData.name),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: AssignPlanSection(child: childData)),
                      SizedBox(width: 32.w),
                      Expanded(flex: 4, child: PlanHistorySection(childName: childData.name)),
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
