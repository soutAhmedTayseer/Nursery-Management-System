import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/overview_cubit.dart';
import '../cubit/overview_state.dart';
import '../widgets/alerts_notifications_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/live_activity_feed.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OverviewCubit()..fetchDashboardData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6F2), // درجة الأوف وايت الفاتحة جداً للديزاين
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32.w), // Padding محترم مناسب للتابلت
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Header
              Text('overview_title'.tr(), style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
              SizedBox(height: 8.h),
              Text('overview_subtitle'.tr(), style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500)),
              SizedBox(height: 40.h),

              // 2. Top Stats Row (3 Cards)
              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'overview_capacity_title'.tr(),
                      value: '24',
                      subtitle: 'overview_capacity_subtitle'.tr(),
                      icon: Icons.tag_faces_rounded,
                      themeColor: const Color(0xFF4CAF50), // Green
                      bottomWidget: _buildProgressBar(0.7, const Color(0xFF4CAF50)),
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'overview_operations_title'.tr(),
                      value: '56h',
                      subtitle: 'overview_operations_subtitle'.tr(),
                      icon: Icons.schedule,
                      themeColor: const Color(0xFFB08D5B), // Brown/Gold
                      bottomWidget: Row(
                        children: [
                          Icon(Icons.trending_up, color: const Color(0xFFB08D5B), size: 18.w),
                          SizedBox(width: 8.w),
                          Text('overview_trend_last_week'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFFB08D5B))),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'overview_accounts_title'.tr(),
                      value: '1,200',
                      unit: 'finance_currency_aed'.tr(),
                      subtitle: 'overview_accounts_subtitle'.tr(),
                      icon: Icons.account_balance_wallet,
                      themeColor: const Color(0xFFD32F2F), // Red
                      bottomWidget: InkWell(
                        onTap: () {},
                        child: Text('overview_view_ledger'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),

              // 3. Bottom Split View (Feed vs Alerts)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Live Activity
                  const Expanded(
                    flex: 1,
                    child: LiveActivityFeed(),
                  ),
                  SizedBox(width: 48.w), // مسافة فاصلة كبيرة

                  // Right Side: Alerts & Notifications
                  const Expanded(
                    flex: 1,
                    child: AlertsNotificationsSection(),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
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