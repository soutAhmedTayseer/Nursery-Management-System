import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';

/// Mock series per period — no backend endpoint for revenue history yet, so
/// this is illustrative data, not a real report.
const Map<RevenuePeriod, List<double>> _revenueByPeriod = {
  RevenuePeriod.daily: [1200, 1850, 900, 2100, 1700, 2400, 1300],
  RevenuePeriod.weekly: [8200, 10500, 7600, 12300],
  RevenuePeriod.monthly: [32000, 28500, 41000, 39500, 45200, 42850],
};

const Map<RevenuePeriod, List<String>> _labelsByPeriod = {
  RevenuePeriod.daily: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  RevenuePeriod.weekly: ['W1', 'W2', 'W3', 'W4'],
  RevenuePeriod.monthly: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
};

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, this.chartHeight = 160});

  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12.h,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('finance_revenue_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text('finance_revenue_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
            _buildPeriodSelector(context),
          ],
        ),
        SizedBox(height: 24.h),
        BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            final values = _revenueByPeriod[state.revenuePeriod]!;
            final labels = _labelsByPeriod[state.revenuePeriod]!;
            final maxValue = values.reduce((a, b) => a > b ? a : b);
            return SizedBox(
              height: chartHeight.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: _buildBar(context, values[i], maxValue, labels[i]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(color: AppColors.surfaceSmoke, borderRadius: BorderRadius.circular(20.r)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _periodBtn(context, RevenuePeriod.daily, 'finance_period_daily'.tr(), state.revenuePeriod),
              _periodBtn(context, RevenuePeriod.weekly, 'finance_period_weekly'.tr(), state.revenuePeriod),
              _periodBtn(context, RevenuePeriod.monthly, 'finance_period_monthly'.tr(), state.revenuePeriod),
            ],
          ),
        );
      },
    );
  }

  Widget _periodBtn(BuildContext context, RevenuePeriod period, String label, RevenuePeriod active) {
    final isActive = period == active;
    return InkWell(
      onTap: () => context.read<FinanceCubit>().setRevenuePeriod(period),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double value, double maxValue, String label) {
    final fraction = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.05, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          value.toInt().toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
        ),
        SizedBox(height: 6.h),
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
