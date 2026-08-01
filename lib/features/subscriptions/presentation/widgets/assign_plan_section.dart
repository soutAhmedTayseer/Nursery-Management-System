import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../data/models/subscription_plan.dart';

class AssignPlanSection extends StatefulWidget {
  final KidSession child;
  final String currentPlanTitle;
  final String currentPlanPrice;
  final ValueChanged<SubscriptionPlan> onPlanUpdated;

  const AssignPlanSection({
    super.key,
    required this.child,
    required this.currentPlanTitle,
    required this.currentPlanPrice,
    required this.onPlanUpdated,
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

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('assign_plan_title'.tr(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),

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

          Text('assign_plan_current_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.green.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.currentPlanTitle, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                Text(widget.currentPlanPrice, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Text('assign_plan_change_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPlanId,
                isExpanded: true,
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text('assign_plan_select_new'.tr(), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                icon: Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600)),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedPlanId == null ? null : _applyUpdate,
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              label: Text('assign_plan_update_button'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                disabledBackgroundColor: AppColors.leafGreen.withValues(alpha: 0.4),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
