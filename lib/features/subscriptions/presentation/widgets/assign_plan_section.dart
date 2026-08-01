import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../data/models/subscription_plan.dart';

class AssignPlanSection extends StatefulWidget {
  final KidSession child;
  final String currentPlanTitle;
  final String currentPlanPrice;
  final ValueChanged<SubscriptionPlan> onPlanUpdated;

  /// Set false when embedded where the child's photo/name/parent are
  /// already shown elsewhere (e.g. ChildProfileDetailsScreen's left card).
  final bool showChildTile;

  const AssignPlanSection({
    super.key,
    required this.child,
    required this.currentPlanTitle,
    required this.currentPlanPrice,
    required this.onPlanUpdated,
    this.showChildTile = true,
  });

  @override
  State<AssignPlanSection> createState() => _AssignPlanSectionState();
}

class _AssignPlanSectionState extends State<AssignPlanSection> {
  String? _selectedPlanId;

  void _applyUpdate() {
    final plan = findPlanById(_selectedPlanId);
    if (plan == null) return;
    widget.onPlanUpdated(plan);
    setState(() => _selectedPlanId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('assign_plan_updated_snackbar'.tr(namedArgs: {'plan': plan.titleKey.tr()}))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kid = widget.child.kid;
    final parentName = kid.emergencyContactName.isNotEmpty ? kid.emergencyContactName : widget.child.planLabel;
    final showChildTile = widget.showChildTile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(48.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(48.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('assign_plan_title'.tr(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 20.h),

              if (showChildTile) ...[
            // Child Info Tile
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: kid.photoUrl.isEmpty ? null : NetworkImage(kid.photoUrl),
                    onBackgroundImageError: kid.photoUrl.isEmpty ? null : (_, _) {},
                    child: kid.photoUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kid.fullName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text('assign_plan_parent_name_label'.tr(namedArgs: {'name': parentName}), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8.r)),
                    child: Text('subscription_active_badge'.tr(), style: TextStyle(fontSize: 9.sp, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

              Text('assign_plan_current_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.6)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(color: AppColors.surfaceSand, borderRadius: BorderRadius.circular(48.r)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.currentPlanTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    Text(widget.currentPlanPrice, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              Text('assign_plan_change_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.6)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(color: AppColors.neutralChip, borderRadius: BorderRadius.circular(48.r)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPlanId,
                    isExpanded: true,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text('assign_plan_select_new'.tr(), style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    icon: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: SvgPicture.asset('assets/icons/subscriptions/dropdown_chevron.svg', width: 21.w, height: 21.w),
                    ),
                    items: kSubscriptionPlans
                        .map((plan) => DropdownMenuItem(
                              value: plan.id,
                              child: Text('${plan.titleKey.tr()} — ${plan.price}', style: TextStyle(fontSize: 14.sp)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedPlanId = value),
                  ),
                ),
              ),

              SizedBox(height: 32.h),
              InkWell(
                onTap: _selectedPlanId == null ? null : _applyUpdate,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: _selectedPlanId == null
                          ? [AppColors.darkGreen.withValues(alpha: 0.4), AppColors.brandGradientLight.withValues(alpha: 0.4)]
                          : [AppColors.darkGreen, AppColors.brandGradientLight],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/subscriptions/swap_icon.svg', width: 13.3.w, height: 12.w),
                      SizedBox(width: 8.w),
                      Text('assign_plan_update_button'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
