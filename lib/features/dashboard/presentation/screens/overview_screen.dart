import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mouse_wheel_horizontal_scroll.dart';
import '../cubit/overview_cubit.dart';
import '../widgets/alerts_notifications_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/live_activity_feed.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final isCompact = context.isCompact;
    final scale = context.uiScale;
    final statCards = [
      DashboardStatCard(
        title: 'overview_capacity_title'.tr(),
        value: '24',
        subtitle: 'overview_capacity_subtitle'.tr(),
        icon: Icons.tag_faces_rounded,
        themeColor: AppColors.successGreen,
        bottomWidget: _buildProgressBar(0.7, AppColors.successGreen),
      ),
      DashboardStatCard(
        title: 'overview_operations_title'.tr(),
        value: '56h',
        subtitle: 'overview_operations_subtitle'.tr(),
        icon: Icons.schedule,
        themeColor: AppColors.gold,
        bottomWidget: Row(
          children: [
            Icon(Icons.trending_up, color: AppColors.gold, size: (18 * scale).w),
            SizedBox(width: 8.w),
            Text('overview_trend_last_week'.tr(), style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.gold)),
          ],
        ),
      ),
      DashboardStatCard(
        title: 'overview_accounts_title'.tr(),
        value: '1,200',
        unit: 'finance_currency_aed'.tr(),
        subtitle: 'overview_accounts_subtitle'.tr(),
        icon: Icons.account_balance_wallet,
        themeColor: AppColors.errorRed,
        bottomWidget: InkWell(
          onTap: () {},
          child: Text('overview_view_ledger'.tr(), style: TextStyle(fontSize: (14 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        ),
      ),
    ];
    final availableWidth = MediaQuery.sizeOf(context).width - spacing.pagePadding * 2;
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

    // Feed and alerts panels each pin their own header and scroll their own
    // content — so the whole screen fits without a page-level scroll on any
    // breakpoint.
    final panels = isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: LiveActivityFeed()),
              SizedBox(height: spacing.xxl),
              const Expanded(child: AlertsNotificationsSection()),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: LiveActivityFeed()),
              SizedBox(width: spacing.xxl),
              const Expanded(child: AlertsNotificationsSection()),
            ],
          );

    return BlocProvider(
      create: (context) => OverviewCubit()..fetchDashboardData(),
      child: Scaffold(
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
      ),
    );
  }

  // ويدجت مساعدة لشريط التقدم الأخضر
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