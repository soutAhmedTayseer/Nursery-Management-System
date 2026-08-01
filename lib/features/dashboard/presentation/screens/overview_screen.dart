import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/overview_cubit.dart';
import '../widgets/alerts_notifications_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/live_activity_feed.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
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
            Icon(Icons.trending_up, color: AppColors.gold, size: 18.w),
            SizedBox(width: 8.w),
            Text('overview_trend_last_week'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.gold)),
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
          child: Text('overview_view_ledger'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        ),
      ),
    ];
    final columns = const ResponsiveValue<int>(compact: 1, medium: 2, expanded: 3).resolve(context);
    final cardWidth = (MediaQuery.sizeOf(context).width -
            spacing.pagePadding * 2 -
            spacing.gutter * (columns - 1)) /
        columns;

    return BlocProvider(
      create: (context) => OverviewCubit()..fetchDashboardData(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceCream,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Header
              Text('overview_title'.tr(), style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
              SizedBox(height: spacing.xs),
              Text('overview_subtitle'.tr(), style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500)),
              SizedBox(height: spacing.xxl),

              // 2. Top Stats (1/2/3 columns by breakpoint)
              Wrap(
                spacing: spacing.gutter,
                runSpacing: spacing.gutter,
                children: [
                  for (final card in statCards) SizedBox(width: cardWidth, child: card),
                ],
              ),
              SizedBox(height: spacing.xxl),

              // 3. Bottom Split View (Feed vs Alerts) - stacks at compact
              if (context.isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LiveActivityFeed(),
                    SizedBox(height: spacing.xxl),
                    const AlertsNotificationsSection(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 1, child: LiveActivityFeed()),
                    SizedBox(width: spacing.xxl),
                    const Expanded(flex: 1, child: AlertsNotificationsSection()),
                  ],
                ),

              SizedBox(height: spacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لشريط التقدم الأخضر
  Widget _buildProgressBar(double percentage, Color color) {
    return Container(
      height: 4.h,
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