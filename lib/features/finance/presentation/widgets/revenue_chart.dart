import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class _CategorySeries {
  const _CategorySeries({required this.labelKey, required this.color, required this.values});

  final String labelKey;
  final Color color;
  final List<double> values;
}

/// Mock per-category monthly revenue — no backend revenue-history endpoint
/// yet, so this is illustrative data, not a real report. Real category
/// linkage (subscriptions_) lands in a later phase.
const _kMonths = ['Sep', 'Oct', 'Nov', 'Dec'];

const _kSeries = [
  _CategorySeries(labelKey: 'finance_series_monthly_plans', color: AppColors.darkGreen, values: [18000, 21000, 19500, 24000]),
  _CategorySeries(labelKey: 'finance_series_daily_sessions', color: AppColors.subscriptionBrown, values: [7000, 6200, 8100, 9500]),
  _CategorySeries(labelKey: 'finance_series_winter_camp', color: AppColors.amberLabel, values: [3000, 3400, 3200, 9350]),
];

/// Monthly revenue breakdown by plan category — a legend row plus one
/// grouped bar cluster per month, current month highlighted.
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
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: [for (final series in _kSeries) _legendDot(series)],
            ),
          ],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: chartHeight.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _kMonths.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: _buildMonthGroup(i, i == _kMonths.length - 1),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(_CategorySeries series) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10.w, height: 12.h, decoration: BoxDecoration(color: series.color, borderRadius: BorderRadius.circular(999))),
        SizedBox(width: 8.w),
        Text(series.labelKey.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildMonthGroup(int monthIndex, bool isCurrent) {
    final maxValue = _kSeries.map((s) => s.values[monthIndex]).reduce((a, b) => a > b ? a : b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final series in _kSeries)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: _bar(series.values[monthIndex], maxValue, series.color),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _kMonths[monthIndex],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            color: isCurrent ? AppColors.darkGreen : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _bar(double value, double maxValue, Color color) {
    final fraction = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.05, 1.0);
    return SizedBox(
      width: 12.w,
      child: FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: fraction,
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.vertical(top: Radius.circular(4.r))),
        ),
      ),
    );
  }
}
