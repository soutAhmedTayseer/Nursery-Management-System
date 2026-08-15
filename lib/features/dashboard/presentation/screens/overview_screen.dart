import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/testing/attendance_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mouse_wheel_horizontal_scroll.dart';
import '../../../admin_main_layout/presentation/cubit/admin_main_layout_cubit.dart';
import '../../../finance/data/models/finance_model.dart';
import '../../domain/nursery_alerts.dart';
import '../../../finance/presentation/cubit/finance_cubit.dart';
import '../../../finance/presentation/cubit/finance_state.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../../settings/data/app_settings.dart';
import '../../../settings/presentation/cubit/app_settings_cubit.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_state.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';
import '../../../subscriptions/presentation/cubit/plans_state.dart';
import '../cubit/overview_cubit.dart';
import '../cubit/overview_state.dart';
import '../widgets/alerts_notifications_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/live_activity_feed.dart';
import '../../../../core/theme/app_palette.dart';

/// Finance index in AdminMainLayoutScreen's nav — see that file's `screens`
/// list. Kept as a constant here rather than threading a callback through,
/// since both are in the same admin shell and this is the only cross-tab
/// jump on this screen.
const _financeTabIndex = 4;

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spacing = AppSpacing.of(context);
    final isCompact = context.isCompact;

    return BlocProvider(
      create: (_) =>
          OverviewCubit(sl<SessionsRepository>())..fetchDashboardData(),
      child: Builder(
        // Clocking a child in/out anywhere (Sessions grid, QR scan, or the
        // "Check Out" action on an alert right here) changes today's
        // occupancy and hours, so re-pull the dashboard figures whenever the
        // roster moves instead of showing a stale snapshot.
        builder: (context) => BlocListener<SessionsCubit, SessionsState>(
          listener: (context, _) => context.read<OverviewCubit>().fetchDashboardData(),
          child: BlocBuilder<OverviewCubit, OverviewState>(
          builder: (context, overview) => BlocBuilder<AppSettingsCubit, AppSettings>(
            builder: (context, appSettings) =>
                BlocBuilder<PlanAssignmentsCubit, PlanAssignmentsState>(
                  builder: (context, assignments) =>
                      BlocBuilder<PlansCubit, PlansState>(
                        builder: (context, plans) =>
                            BlocBuilder<FinanceCubit, FinanceState>(
                              builder: (context, finance) {
                                final capacity = appSettings.capacity;
                                // Server-computed (contract §2). total_outstanding
                                // already excludes settled invoices, so this is
                                // read rather than summed here.
                                final records = finance.records;
                                final pendingDues =
                                    finance.summary?.totalOutstanding ?? 0;
                                final allowedHoursByKidId = {
                                  for (final assignment in assignments.byKidId.values)
                                    assignment.kidId: plans
                                        .categories
                                        .expand((c) => c.lineItems)
                                        .where((i) => i.id == assignment.lineItemId)
                                        .firstOrNull
                                        ?.hoursPerDay,
                                };
                                final alertList = buildNurseryAlerts(
                                  records: records,
                                  allowedHoursByKidId: allowedHoursByKidId,
                                );

                                final statCards = _buildStatCards(
                                  context,
                                  overview,
                                  records,
                                  pendingDues,
                                  finance.revenue.isEmpty
                                      ? 0.0
                                      : finance.revenue.last.revenue,
                                  capacity,
                                  assignments,
                                  plans,
                                );
                                final availableWidth =
                                    MediaQuery.sizeOf(context).width -
                                    spacing.pagePadding * 2;
                                final scale = context.uiScale;
                                final cardWidth =
                                    ((availableWidth -
                                                spacing.gutter *
                                                    (statCards.length - 1)) /
                                            statCards.length)
                                        .clamp(
                                          kDashboardStatCardMinWidth * scale,
                                          kDashboardStatCardMaxWidth * scale,
                                        );
                                // Every card gets the identical box. The row
                                // scrolls horizontally, so with more cards
                                // than fit they shrink to the 240 floor and
                                // scroll rather than squeezing out of shape.
                                final cardHeight =
                                    (kDashboardStatCardHeight * scale).h;

                                final statsRow = SizedBox(
                                  height: cardHeight,
                                  child: MouseWheelHorizontalScroll(
                                    child: Row(
                                      children: [
                                        for (
                                          int i = 0;
                                          i < statCards.length;
                                          i++
                                        ) ...[
                                          if (i > 0)
                                            SizedBox(width: spacing.gutter),
                                          SizedBox(
                                            width: cardWidth,
                                            height: cardHeight,
                                            child: statCards[i],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );

                                const feed = LiveActivityFeed();
                                final alerts = AlertsNotificationsSection(
                                  alerts: alertList,
                                );

                                // Feed and alerts panels each pin their own header and scroll
                                // their own content — so the whole screen fits without a
                                // page-level scroll on any breakpoint.
                                final panels = isCompact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: feed),
                                          SizedBox(height: spacing.xxl),
                                          Expanded(child: alerts),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: feed),
                                          SizedBox(width: spacing.xxl),
                                          Expanded(child: alerts),
                                        ],
                                      );

                                return Scaffold(
                                  backgroundColor: palette.page,
                                  body: Padding(
                                    padding: EdgeInsets.all(
                                      spacing.pagePadding,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
        ),
      ),
    );
  }

  List<Widget> _buildStatCards(
    BuildContext context,
    OverviewState overview,
    List<PaymentRecord> records,
    double pendingDues,
    // Server-computed (contract §2): the latest bucket of the revenue series.
    double revenueToday,
    int capacity,
    PlanAssignmentsState assignments,
    PlansState plans,
  ) {
    final scale = context.uiScale;
    final loaded = overview is OverviewLoaded ? overview : null;
    final checkedIn = loaded?.checkedInCount ?? 0;
    final occupancyFraction = capacity == 0
        ? 0.0
        : (checkedIn / capacity).clamp(0, 1).toDouble();

    // Attendance figures still come from the shared ledger; every money
    // figure arrives already computed from the server.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayRecords = AttendanceStore.instance.allOn(today);
    final enrolled = assignments.byKidId.length;
    final attendedToday = todayRecords.length;
    final attendanceRate = enrolled == 0 ? 0.0 : (attendedToday / enrolled).clamp(0, 1).toDouble();

    var overtimeHoursToday = 0.0;
    for (final entry in todayRecords.entries) {
      final assignment = assignments.byKidId[entry.key];
      if (assignment == null) continue;
      final item = plans.categories
          .expand((c) => c.lineItems)
          .where((i) => i.id == assignment.lineItemId)
          .firstOrNull;
      overtimeHoursToday += entry.value.overtimeHours(item?.hoursPerDay);
    }
    final unpaidCount = records.where((record) => !record.isPaid && record.totalDue > 0).length;

    return [
      DashboardStatCard(
        title: 'overview_capacity_title'.tr(),
        value: '$checkedIn',
        unit: 'overview_capacity_unit'.tr(namedArgs: {'capacity': '$capacity'}),
        subtitle: 'overview_capacity_subtitle'.tr(),
        icon: Icons.tag_faces_rounded,
        themeColor: AppColors.successGreen,
        bottomWidget: _buildProgressBar(context, 
          occupancyFraction,
          AppColors.successGreen,
        ),
        onTap: () => _editCapacity(context, capacity),
      ),
      DashboardStatCard(
        title: 'overview_operations_title'.tr(),
        value: '${loaded?.totalHoursToday.toStringAsFixed(0) ?? 0}h',
        subtitle: 'overview_operations_subtitle'.tr(),
        icon: Icons.schedule,
        themeColor: AppColors.gold,
        bottomWidget: Row(
          children: [
            Icon(
              Icons.trending_up,
              color: AppColors.gold,
              size: (18 * scale).w,
            ),
            SizedBox(width: 8.w),
            // No historical backend yet to compute a real week-over-week
            // trend — illustrative, matches the Figma reference copy.
            Text(
              'overview_trend_last_week'.tr(),
              style: TextStyle(
                fontSize: (12 * scale).sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
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
          onTap: () => context.read<AdminMainLayoutCubit>().changeScreen(
            _financeTabIndex,
          ),
          child: Text(
            'overview_view_ledger'.tr(),
            style: TextStyle(
              fontSize: (14 * scale).sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ),
      DashboardStatCard(
        title: 'overview_revenue_today_title'.tr(),
        value: revenueToday.toStringAsFixed(0),
        unit: 'finance_currency_aed'.tr(),
        subtitle: 'overview_revenue_today_subtitle'.tr(),
        icon: Icons.trending_up_rounded,
        themeColor: AppColors.darkGreen,
      ),
      DashboardStatCard(
        title: 'overview_overtime_today_title'.tr(),
        value: overtimeHoursToday.toStringAsFixed(1),
        unit: 'overview_hours_unit'.tr(),
        subtitle: 'overview_overtime_today_subtitle'.tr(),
        icon: Icons.more_time_rounded,
        themeColor: AppColors.penaltyOrange,
      ),
      DashboardStatCard(
        title: 'overview_attendance_today_title'.tr(),
        value: '$attendedToday',
        unit: 'overview_of_enrolled_unit'.tr(namedArgs: {'total': '$enrolled'}),
        subtitle: 'overview_attendance_today_subtitle'.tr(),
        icon: Icons.fact_check_outlined,
        themeColor: AppColors.accentGreen,
        bottomWidget: _buildProgressBar(context, attendanceRate, AppColors.accentGreen),
      ),
      DashboardStatCard(
        title: 'overview_unpaid_title'.tr(),
        value: '$unpaidCount',
        unit: 'overview_invoices_unit'.tr(),
        subtitle: 'overview_unpaid_subtitle'.tr(),
        icon: Icons.receipt_long_outlined,
        themeColor: AppColors.amberLabel,
        onTap: () => context.read<AdminMainLayoutCubit>().changeScreen(_financeTabIndex),
      ),
    ];
  }

  Future<void> _editCapacity(BuildContext context, int currentCapacity) async {
    final cubit = context.read<AppSettingsCubit>();
    final controller = TextEditingController(text: '$currentCapacity');
    final newCapacity = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('overview_capacity_edit_title'.tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'overview_capacity_edit_label'.tr(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('action_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(int.tryParse(controller.text)),
            child: Text('overview_capacity_edit_save'.tr()),
          ),
        ],
      ),
    );
    if (newCapacity != null && newCapacity > 0) cubit.updateNursery(capacity: newCapacity);
  }

  Widget _buildProgressBar(BuildContext context, double percentage, Color color) {
    final palette = context.palette;
    return Container(
      height: 5.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.chip,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}
