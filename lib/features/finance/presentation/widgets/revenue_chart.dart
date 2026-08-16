import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/finance_repository.dart';
import '../../../../core/theme/app_palette.dart';

enum RevenuePeriod { daily, weekly, monthly, annual }

class _Bucket {
  const _Bucket({required this.label, required this.total});

  final String label;
  final double total;
}

/// Total revenue over time, switchable between daily / weekly / monthly /
/// annual — one bar per bucket, latest highlighted.
///
/// The series comes from `GET /admin/finance/revenue` — the client draws it and
/// does not sum it (contract §2), and the chart needs history the client never
/// holds, since it only ever has the current page of balances.
class RevenueChart extends StatefulWidget {
  const RevenueChart({
    super.key,
    required this.buckets,
    this.onPeriodChanged,
    this.chartHeight = 160,
  });

  /// Revenue per bucket, oldest first, as the server returned it.
  final List<RevenueBucket> buckets;

  /// Fired when the admin switches period, so the parent can refetch the range.
  final ValueChanged<RevenuePeriod>? onPeriodChanged;

  final double chartHeight;

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  RevenuePeriod _period = RevenuePeriod.monthly;

  /// Labels the buckets the server returned. The period only decides the label
  /// format and which range the parent asked for — no totalling happens here.
  List<_Bucket> _buckets(BuildContext context) {
    final locale = context.locale.languageCode;
    return [
      for (final bucket in widget.buckets)
        _Bucket(label: _labelFor(bucket.start, locale), total: bucket.revenue),
    ];
  }

  String _labelFor(DateTime start, String locale) => switch (_period) {
        RevenuePeriod.daily => DateFormat.E(locale).format(start),
        RevenuePeriod.weekly => DateFormat.Md(locale).format(start),
        RevenuePeriod.monthly => DateFormat.MMM(locale).format(start),
        RevenuePeriod.annual => '${start.year}',
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final buckets = _buckets(context);
    final maxValue = buckets.fold<double>(0, (max, b) => b.total > max ? b.total : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('finance_revenue_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text('finance_revenue_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: palette.textTertiary)),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [for (final period in RevenuePeriod.values) _periodChip(context, period)],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: widget.chartHeight.h,
          child: maxValue == 0
              ? Center(
                  child: Text(
                    'finance_revenue_empty'.tr(),
                    style: TextStyle(fontSize: 13.sp, color: palette.textTertiary),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < buckets.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: _bar(context, buckets[i], maxValue, i == buckets.length - 1),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _periodChip(BuildContext context, RevenuePeriod period) {

  final palette = context.palette;
    final isActive = period == _period;
    return InkWell(
      onTap: () {
        setState(() => _period = period);
        // The parent owns the fetch — a different period is a different date
        // range, which only the server can answer.
        widget.onPeriodChanged?.call(period);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkGreen : palette.chip,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'finance_period_${period.name}'.tr(),
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isActive ? Colors.white : palette.textSecondary),
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, _Bucket bucket, double maxValue, bool isCurrent) {

  final palette = context.palette;
    final fraction = (bucket.total / maxValue).clamp(0.02, 1.0);
    return Tooltip(
      message: '${bucket.label}: ${bucket.total.toStringAsFixed(0)} ${'finance_currency_aed'.tr()}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.darkGreen : AppColors.darkGreen.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            bucket.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: isCurrent ? AppColors.darkGreen : palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
