import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mouse_wheel_horizontal_scroll.dart';
import '../../../admin_main_layout/presentation/cubit/admin_main_layout_cubit.dart';
import '../../../finance/domain/payment_records.dart';
import '../../../finance/presentation/cubit/finance_cubit.dart';
import '../../../finance/presentation/cubit/finance_state.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_state.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';
import '../../../subscriptions/presentation/cubit/plans_state.dart';
import '../cubit/overview_cubit.dart';
import '../cubit/overview_state.dart';
import '../widgets/alerts_notifications_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/live_activity_feed.dart';

/// Finance index in AdminMainLayoutScreen's nav — see that file's `screens`
/// list. Kept as a constant here rather than threading a callback through,
/// since both are in the same admin shell and this is the only cross-tab
/// jump on this screen.
const _financeTabIndex = 4;

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final isCompact = context.isCompact;

    return BlocProvider(
      create: (_) => OverviewCubit(sl<SessionsRepository>())..fetchDashboardData(),
      child: Builder(
        builder: (context) => BlocBuilder<OverviewCubit, OverviewState>(
          builder: (context, overview) => BlocBuilder<PlanAssignmentsCubit, PlanAssignmentsState>(
            builder: (context, assignments) => BlocBuilder<PlansCubit, PlansState>(
              builder: (context, plans) => BlocBuilder<FinanceCubit, FinanceState>(
                builder: (context, finance) {
                  final records = derivePaymentRecords(assignments, plans, finance);
                  final pendingDues = records.fold<double>(0, (sum, r) => sum + r.totalDue);
                  final overtimeAlerts = [
                    for (final r in records)
                      if (r.overtimeHours > 0) OvertimeAlert(kidName: r.childName, overtimeHours: r.overtimeHours),
                  ];

                  final statCards = _buildStatCards(context, overview, pendingDues);
                  final availableWidth = MediaQuery.sizeOf(context).width - spacing.pagePadding * 2;
                  final scale = context.uiScale;
                  final cardWidth = ((availableWidth - spacing.gutter * (statCards.length - 1)) / statCards.length)
                      .clamp(240.0 * scale, 400.0 * scale);

                  final statsRow = MouseWheelHorizontalScroll(
                    child: Row(
                      children: [
                        for (int i = 0; i < statCards.length; i++) ...[
                          if (i > 0) SizedBox(width: spacing.gutter),
                          SizedBox(width: cardWidth, child: statCards[i]),
                        ],
                      ],
                    ),
                  );

                  final feed = overview is OverviewLoaded
                      ? LiveActivityFeed(events: overview.recentEvents)
                      : const Center(child: CircularProgressIndicator());
                  final alerts = AlertsNotificationsSection(alerts: overtimeAlerts);

                  // Feed and alerts panels each pin their own header and scroll
                  // their own content — so the whole screen fits without a
                  // page-level scroll on any breakpoint.
                  final panels = isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: feed),
                            SizedBox(height: spacing.xxl),
                            Expanded(child: alerts),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: feed),
                            SizedBox(width: spacing.xxl),
                            Expanded(child: alerts),
                          ],
                        );

                  return Scaffold(
                    backgroundColor: AppColors.surfaceCream,
                    body: Padding(
                      padding: EdgeInsets.all(spacing.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          statsRow,
                          SizedBox(height: spacing.xxl),
                          Expanded(child: panels),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatCards(BuildContext context, OverviewState overview, double pendingDues) {
    final scale = context.uiScale;
    final loaded = overview is OverviewLoaded ? overview : null;
    return [
      DashboardStatCard(
        title: 'overview_capacity_title'.tr(),
        value: '${loaded?.checkedInCount ?? 0}',
        subtitle: 'overview_capacity_subtitle'.tr(),
        icon: Icons.tag_faces_rounded,
        themeColor: AppColors.successGreen,
        bottomWidget: _buildProgressBar(loaded?.occupancyFraction ?? 0, AppColors.successGreen),
      ),
      DashboardStatCard(
        title: 'overview_operations_title'.tr(),
        value: '${loaded?.totalHoursToday.toStringAsFixed(0) ?? 0}h',
        subtitle: 'overview_operations_subtitle'.tr(),
        icon: Icons.schedule,
        themeColor: AppColors.gold,
        bottomWidget: Row(
          children: [
            Icon(Icons.trending_up, color: AppColors.gold, size: (18 * scale).w),
            SizedBox(width: 8.w),
            // No historical backend yet to compute a real week-over-week
            // trend — illustrative, matches the Figma reference copy.
            Text('overview_trend_last_week'.tr(), style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.gold)),
          ],
        ),
      ),
      DashboardStatCard(
        title: 'overview_accounts_title'.tr(),
        value: pendingDues.toStringAsFixed(0),
        unit: 'finance_currency_aed'.tr(),
        subtitle: 'overview_accounts_subtitle'.tr(),
        icon: Icons.account_balance_wallet,
        themeColor: AppColors.errorRed,
        bottomWidget: InkWell(
          onTap: () => context.read<AdminMainLayoutCubit>().changeScreen(_financeTabIndex),
          child: Text('overview_view_ledger'.tr(), style: TextStyle(fontSize: (14 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        ),
      ),
    ];
  }

  Widget _buildProgressBar(double percentage, Color color) {
    return Container(
      height: 5.h,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2.r)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r))),
      ),
    );
  }
}
