import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mouse_wheel_horizontal_scroll.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../data/models/subscription_plan.dart';
import '../widgets/assign_plan_section.dart';
import '../widgets/global_plan_card.dart';
import '../widgets/plan_history_section.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  final KidSession childData;

  const ManageSubscriptionScreen({super.key, required this.childData});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  // No backend endpoint for plan assignment yet — plan + history live only
  // in this screen's state and reset if the admin navigates away.
  late String _currentPlanTitle = widget.childData.planLabel;
  String _currentPlanPrice = '—';
  final List<PlanChangeEntry> _history = [];

  void _applyPlan(SubscriptionPlan plan) {
    final newTitle = plan.titleKey.tr();
    setState(() {
      _history.insert(0, PlanChangeEntry(
        date: DateTime.now(),
        oldPlanLabel: _currentPlanTitle,
        newPlanLabel: newTitle,
        changedBy: 'Admin',
      ));
      _currentPlanTitle = newTitle;
      _currentPlanPrice = plan.price;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kid = widget.childData.kid;
    final parentName = kid.emergencyContactName.isNotEmpty ? kid.emergencyContactName : kid.fullName;

    return Scaffold(
      backgroundColor: AppColors.surfaceIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.accentGreen, size: 20.w),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Global Plans (Horizontal Scroll)
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

            MouseWheelHorizontalScroll(
              child: Row(
                children: [
                  for (final plan in kSubscriptionPlans) ...[
                    GlobalPlanCard(
                      title: plan.titleKey.tr(),
                      duration: plan.durationKey.tr(),
                      price: plan.price,
                      icon: plan.icon,
                      themeColor: plan.themeColor,
                      isSolid: plan.isSolid,
                    ),
                    SizedBox(width: 16.w),
                  ],
                ],
              ),
            ),
            SizedBox(height: 48.h),

            // 2. Split Layout (Assign Plan & History)
            if (!context.isExpanded) ...[
              AssignPlanSection(
                child: widget.childData,
                currentPlanTitle: _currentPlanTitle,
                currentPlanPrice: _currentPlanPrice,
                onPlanUpdated: _applyPlan,
              ),
              SizedBox(height: 32.h),
              PlanHistorySection(
                childName: kid.fullName,
                parentName: parentName,
                parentPhone: kid.emergencyContactPhone,
                currentPlanTitle: _currentPlanTitle,
                currentPlanPrice: _currentPlanPrice,
                startDate: kid.createdAt,
                history: _history,
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AssignPlanSection(
                      child: widget.childData,
                      currentPlanTitle: _currentPlanTitle,
                      currentPlanPrice: _currentPlanPrice,
                      onPlanUpdated: _applyPlan,
                    ),
                  ),
                  SizedBox(width: 32.w),
                  Expanded(
                    flex: 4,
                    child: PlanHistorySection(
                      childName: kid.fullName,
                      parentName: parentName,
                      parentPhone: kid.emergencyContactPhone,
                      currentPlanTitle: _currentPlanTitle,
                      currentPlanPrice: _currentPlanPrice,
                      startDate: kid.createdAt,
                      history: _history,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
