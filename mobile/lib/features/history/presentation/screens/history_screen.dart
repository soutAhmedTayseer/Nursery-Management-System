import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/  history_state.dart';
import '../cubit/history_cubit.dart';
import '../widgets/daily_breakdown_card.dart';
import '../widgets/history_header_card.dart';
import '../widgets/monthly_summary_cards.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(),
      child: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HistoryHeaderCard(),
                  SizedBox(height: 24.h),

                  const MonthlySummaryCards(),
                  SizedBox(height: 32.h),

                  // Section Title
                  Text('DAILY BREAKDOWN', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
                  SizedBox(height: 16.h),

                  // الليست المفصلة باستخدام الـ Reusable Component
                  const DailyBreakdownCard(
                    date: 'Monday, Oct 12',
                    sessionType: 'Standard Full Day',
                    clockIn: '08:00 AM',
                    clockOut: '05:30 PM',
                    totalTime: '9h 30m',
                    overtime: '+1h',
                  ),
                  const DailyBreakdownCard(
                    date: 'Tuesday, Oct 13',
                    sessionType: 'Morning Session Only',
                    clockIn: '08:00 AM',
                    clockOut: '12:30 PM',
                    totalTime: '4h 30m',
                  ),
                  const DailyBreakdownCard(
                    date: 'Wednesday, Oct 14',
                    sessionType: 'Standard Full Day',
                    clockIn: '08:15 AM',
                    clockOut: '05:15 PM',
                    totalTime: '9h 00m',
                    overtime: '+30m',
                  ),
                  const DailyBreakdownCard(
                    date: 'Thursday, Oct 15',
                    sessionType: 'Standard Full Day',
                    clockIn: '08:00 AM',
                    clockOut: '05:00 PM',
                    totalTime: '9h 00m',
                  ),

                  SizedBox(height: 40.h),
                  // Footer Logo Placeholder
                  Center(child: Icon(Icons.eco, size: 48.w, color: Colors.grey.shade300)),
                  SizedBox(height: 100.h), // لتفادي الـ Bottom Nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}