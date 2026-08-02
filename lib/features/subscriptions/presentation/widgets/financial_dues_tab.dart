import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../data/models/subscription_plan.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import 'assign_plan_section.dart';
import 'plan_category_card.dart';
import 'plan_category_edit_dialog.dart';
import 'plan_history_section.dart';

/// Body content of subscription management — global plans, assign-plan
/// form, and plan history/export. Extracted from ManageSubscriptionScreen
/// so it can be embedded as the Financial Dues tab of
/// ChildProfileDetailsScreen (no Scaffold/AppBar of its own) as well as
/// used standalone.
class FinancialDuesTab extends StatefulWidget {
  const FinancialDuesTab({super.key, required this.childData, this.onPlanChanged, this.showChildIdentity = true});

  final KidSession childData;

  /// Fired with the current plan (title, price) on load and after every
  /// update, so an ancestor (e.g. a profile-export button) can include it
  /// without duplicating the plan state.
  final void Function(String title, String price)? onPlanChanged;

  /// Set false when embedded where the child's name/photo are already
  /// shown elsewhere (e.g. ChildProfileDetailsScreen's header). Standalone
  /// usage (ManageSubscriptionScreen) has nowhere else to show identity, so
  /// it stays true there.
  final bool showChildIdentity;

  @override
  State<FinancialDuesTab> createState() => _FinancialDuesTabState();
}

int _columnsFor(BuildContext context) => switch (context.breakpoint) {
      Breakpoint.compact => 1,
      Breakpoint.medium => 2,
      Breakpoint.expanded => 3,
    };

class _FinancialDuesTabState extends State<FinancialDuesTab> {
  // No backend endpoint for plan assignment yet — plan + history live only
  // in this widget's state and reset if the admin navigates away.
  late String _currentPlanTitle = widget.childData.planLabel;
  String _currentPlanPrice = '—';
  final List<PlanChangeEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPlanChanged?.call(_currentPlanTitle, _currentPlanPrice);
    });
  }

  void _applyPlan(PlanCategory category, PlanLineItem item) {
    setState(() {
      _history.insert(0, PlanChangeEntry(
        date: DateTime.now(),
        oldPlanLabel: _currentPlanTitle,
        newPlanLabel: item.label,
        changedBy: 'Admin',
      ));
      _currentPlanTitle = item.label;
      _currentPlanPrice = item.price;
    });
    widget.onPlanChanged?.call(_currentPlanTitle, _currentPlanPrice);
  }

  @override
  Widget build(BuildContext context) {
    final kid = widget.childData.kid;
    final parentName = kid.emergencyContactName.isNotEmpty ? kid.emergencyContactName : kid.fullName;
    final spacing = AppSpacing.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Global Plans (Bento Grid — matches Figma "Manage Subscriptions", node 4:1111)
        BlocBuilder<PlansCubit, PlansState>(
          builder: (context, state) {
            final columns = _columnsFor(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/subscriptions/plans_heading.svg', width: 20.w, height: 20.w),
                        SizedBox(width: 8.w),
                        Text('subscriptions_global_plans_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(color: AppColors.activePlansBadgeBg, borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        'subscriptions_active_plans_badge'.tr(namedArgs: {'count': '${state.categories.length}'}),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.amberLabel, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - spacing.gutter * (columns - 1)) / columns;
                    return Wrap(
                      spacing: spacing.gutter,
                      runSpacing: spacing.gutter,
                      children: [
                        for (final category in state.categories)
                          SizedBox(
                            width: cardWidth,
                            child: PlanCategoryCard(
                              category: category,
                              onEdit: () => PlanCategoryEditDialog.show(context, category: category),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
        SizedBox(height: 48.h),

        // 2. Split Layout (Assign Plan & History)
        if (!context.isExpanded) ...[
          AssignPlanSection(
            child: widget.childData,
            currentPlanTitle: _currentPlanTitle,
            currentPlanPrice: _currentPlanPrice,
            onPlanUpdated: _applyPlan,
            showChildTile: widget.showChildIdentity,
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
            showChildName: widget.showChildIdentity,
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
                  showChildTile: widget.showChildIdentity,
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
                  showChildName: widget.showChildIdentity,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
