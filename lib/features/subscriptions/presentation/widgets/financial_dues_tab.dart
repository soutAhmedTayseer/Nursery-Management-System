import 'dart:async';

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
import '../cubit/plan_assignments_cubit.dart';
import '../cubit/plan_history_cubit.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import 'assign_plan_section.dart';
import 'plan_category_card.dart';
import 'plan_history_section.dart';
import '../../../../core/theme/app_palette.dart';

/// Body content of subscription management — global plans, assign-plan
/// form, and plan history/export. Extracted from ManageSubscriptionScreen
/// so it can be embedded as the Financial Dues tab of
/// ChildProfileDetailsScreen (no Scaffold/AppBar of its own) as well as
/// used standalone.
class FinancialDuesTab extends StatefulWidget {
  const FinancialDuesTab({super.key, required this.childData, this.onPlanChanged, this.showChildIdentity = true});

  final KidSession childData;

  /// Fired with the current plan (title, price) and full display history on
  /// load and after every update, so an ancestor (e.g. a profile-export
  /// button) can include them without duplicating the plan state.
  final void Function(String title, String price, List<PlanChangeEntry> history)? onPlanChanged;

  /// Set false when embedded where the child's name/photo are already
  /// shown elsewhere (e.g. ChildProfileDetailsScreen's header). Standalone
  /// usage (ManageSubscriptionScreen) has nowhere else to show identity, so
  /// it stays true there.
  final bool showChildIdentity;

  @override
  State<FinancialDuesTab> createState() => _FinancialDuesTabState();
}

class _FinancialDuesTabState extends State<FinancialDuesTab> {
  // Both the current plan (PlanAssignmentsCubit) and its change history
  // (PlanHistoryCubit) live at app root, so neither resets when the admin
  // leaves this tab.
  late String _currentPlanTitle;
  late String _currentPlanPrice;

  List<PlanChangeEntry> get _history => context.read<PlanHistoryCubit>().forKid(widget.childData.kid.id);

  @override
  void initState() {
    super.initState();
    _currentPlanTitle = widget.childData.planLabel;
    _currentPlanPrice = '—';
    final assignment = context.read<PlanAssignmentsCubit>().forKid(widget.childData.kid.id);
    if (assignment != null) {
      final result = context.read<PlansCubit>().findLineItem(assignment.categoryId, assignment.lineItemId);
      if (result != null) {
        _currentPlanTitle = result.$2.label;
        _currentPlanPrice = result.$2.price;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPlanChanged?.call(_currentPlanTitle, _currentPlanPrice, _displayHistory);
    });
  }

  /// [_history] already carries an entry for every real plan change — its
  /// top row's `newPlanLabel` IS the current plan, with a real
  /// `oldPlanLabel` (not a placeholder). Only when the child has never
  /// changed plans do we synthesize one row for the initial assignment, so
  /// Plan History isn't empty for a child on their first plan.
  List<PlanChangeEntry> get _displayHistory => _history.isNotEmpty
      ? _history
      : [
          PlanChangeEntry(
            date: widget.childData.kid.createdAt,
            oldPlanLabel: 'plan_history_initial_assignment'.tr(),
            newPlanLabel: _currentPlanTitle,
            changedBy: 'Admin',
          ),
        ];

  void _applyPlan(PlanCategory category, PlanLineItem item) {
    // History is no longer written here: the server appends a PlanChange on
    // every successful assignment (contract §2), which keeps the log honest
    // even when a plan is later renamed. Re-read it instead of inventing a row.
    unawaited(
      context.read<PlanHistoryCubit>().loadForKid(widget.childData.kid.id),
    );
    setState(() {
      _currentPlanTitle = item.label;
      _currentPlanPrice = item.price;
    });
    widget.onPlanChanged?.call(_currentPlanTitle, _currentPlanPrice, _displayHistory);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final kid = widget.childData.kid;
    final parentName = kid.emergencyContactName.isNotEmpty ? kid.emergencyContactName : kid.fullName;
    final spacing = AppSpacing.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Global Plans (Bento Grid — matches Figma "Manage Subscriptions", node 4:1111)
        BlocBuilder<PlansCubit, PlansState>(
          builder: (context, state) {
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
                        Text('subscriptions_global_plans_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(color: AppColors.activePlansBadgeBg, borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        'subscriptions_active_plans_badge'.tr(namedArgs: {'count': '${state.categories.length}'}),
                        style: TextStyle(fontSize: 12.sp, color: palette.amberText, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                // Read-only carousel: 3 cards visible + a sliver of the 4th so
                // the admin knows to swipe, instead of an unbounded stack of
                // editable cards. IntrinsicHeight (not a fixed SizedBox) so
                // the row's height matches the tallest card's real content —
                // a fixed height overflowed whenever a category had enough
                // line items to need more room.
                LayoutBuilder(
                  builder: (context, constraints) {
                    // A fixed comfortable width rather than dividing the
                    // available space by "however many should be visible" —
                    // that division is what squeezed the card down to single
                    // letters wrapping one per line whenever this tab is
                    // narrow (a phone-width window, or split beside the
                    // assign/history panels). This is a carousel: the row
                    // already scrolls, so the card can just be as wide as it
                    // needs to read comfortably and let scrolling handle the
                    // rest, rather than shrinking to force 3 into view.
                    final available = constraints.maxWidth - spacing.gutter * 2;
                    // Never wider than 340 (no point stretching past a
                    // comfortable reading width) and never narrower than 260
                    // (below that a "days / hours — AED" line stops fitting
                    // on one line even at the smallest text scale) —
                    // anything past either edge scrolls instead of squeezing.
                    final cardWidth = available.clamp(260.w, 340.w);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final category in state.categories)
                              Padding(
                                padding: EdgeInsets.only(right: spacing.gutter),
                                child: SizedBox(width: cardWidth, child: PlanCategoryCard(category: category)),
                              ),
                          ],
                        ),
                      ),
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
            history: _displayHistory,
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
                  history: _displayHistory,
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
