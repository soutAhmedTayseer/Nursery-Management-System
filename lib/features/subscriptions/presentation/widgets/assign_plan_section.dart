import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../data/models/plan_assignment.dart';
import '../../data/models/subscription_plan.dart';
import '../cubit/plan_assignments_cubit.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import '../../../../core/theme/app_palette.dart';

class AssignPlanSection extends StatefulWidget {
  final KidSession child;
  final String currentPlanTitle;
  final String currentPlanPrice;
  final void Function(PlanCategory category, PlanLineItem item) onPlanUpdated;

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
  String? _selectedCompositeId; // "<categoryId>:<lineItemId>"

  void _applyUpdate() {
    final parts = _selectedCompositeId?.split(':');
    if (parts == null || parts.length != 2) return;
    final result = context.read<PlansCubit>().findLineItem(parts[0], parts[1]);
    if (result == null) return;
    final (category, item) = result;
    final kid = widget.child.kid;
    final parentName = kid.emergencyContactName.isNotEmpty ? kid.emergencyContactName : widget.child.planLabel;
    context.read<PlanAssignmentsCubit>().assign(PlanAssignment(
          kidId: kid.id,
          kidName: kid.fullName,
          parentName: parentName,
          parentPhone: kid.emergencyContactPhone,
          categoryId: category.id,
          lineItemId: item.id,
          assignedAt: DateTime.now(),
        ));
    widget.onPlanUpdated(category, item);
    setState(() => _selectedCompositeId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('assign_plan_updated_snackbar'.tr(namedArgs: {'plan': item.label}))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
              Text('assign_plan_title'.tr(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
              SizedBox(height: 20.h),

              if (showChildTile) ...[
            // Child Info Tile
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(20.r)),
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
                        Text('assign_plan_parent_name_label'.tr(namedArgs: {'name': parentName}), style: TextStyle(fontSize: 11.sp, color: palette.textTertiary)),
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

              Text('assign_plan_current_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: palette.textSecondary, letterSpacing: 0.6)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(color: palette.sand, borderRadius: BorderRadius.circular(48.r)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.currentPlanTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: palette.textPrimary)),
                    Text(widget.currentPlanPrice, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: palette.brandText)),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              Text('assign_plan_change_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: palette.textSecondary, letterSpacing: 0.6)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(color: palette.chip, borderRadius: BorderRadius.circular(48.r)),
                child: BlocBuilder<PlansCubit, PlansState>(
                  builder: (context, state) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCompositeId,
                        isExpanded: true,
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text('assign_plan_select_new'.tr(), style: TextStyle(fontSize: 14.sp, color: palette.textPrimary)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        icon: Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: SvgPicture.asset('assets/icons/subscriptions/dropdown_chevron.svg', width: 21.w, height: 21.w),
                        ),
                        items: [
                          for (final category in state.categories)
                            for (final item in category.lineItems)
                              DropdownMenuItem(
                                value: '${category.id}:${item.id}',
                                child: Text('${category.name} · ${item.label} — ${item.price}', style: TextStyle(fontSize: 14.sp)),
                              ),
                        ],
                        onChanged: (value) => setState(() => _selectedCompositeId = value),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32.h),
              InkWell(
                onTap: _selectedCompositeId == null ? null : _applyUpdate,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: _selectedCompositeId == null
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
