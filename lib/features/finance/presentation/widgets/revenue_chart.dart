import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_state.dart';
import '../../../subscriptions/presentation/cubit/plans_state.dart';
import '../../domain/payment_records.dart';
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
/// Every figure is computed from the shared attendance ledger and the real
/// plan catalog (see [revenueForRange]), so clocking a child in or changing
/// a plan price moves these bars. Nothing here is hardcoded.
class RevenueChart extends StatefulWidget {
  const RevenueChart({
    super.key,
    required this.assignments,
    required this.plans,
    this.chartHeight = 160,
  });

  final PlanAssignmentsState assignments;
  final PlansState plans;
  final double chartHeight;

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  RevenuePeriod _period = RevenuePeriod.monthly;

  List<_Bucket> _buckets(BuildContext context) {
    final locale = context.locale.languageCode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    double range(DateTime from, DateTime to) => revenueForRange(widget.assignments, widget.plans, from, to);

    switch (_period) {
      case RevenuePeriod.daily:
        // The last 7 days, oldest first.
        return [
          for (var i = 6; i >= 0; i--)
            () {
              final day = today.subtract(Duration(days: i));
              return _Bucket(
                label: DateFormat.E(locale).format(day),
                total: range(day, day.add(const Duration(days: 1))),
              );
            }(),
        ];
      case RevenuePeriod.weekly:
        return [
          for (var i = 3; i >= 0; i--)
            () {
              final end = today.subtract(Duration(days: 7 * i)).add(const Duration(days: 1));
              final start = end.subtract(const Duration(days: 7));
              return _Bucket(label: 'W${4 - i}', total: range(start, end));
            }(),
        ];
      case RevenuePeriod.monthly:
        return [
          for (var i = 3; i >= 0; i--)
            () {
              final start = DateTime(now.year, now.month - i, 1);
              final end = DateTime(now.year, now.month - i + 1, 1);
              return _Bucket(label: DateFormat.MMM(locale).format(start), total: range(start, end));
            }(),
        ];
      case RevenuePeriod.annual:
        return [
          for (var i = 3; i >= 0; i--)
            () {
              final start = DateTime(now.year - i, 1, 1);
              final end = DateTime(now.year - i + 1, 1, 1);
              return _Bucket(label: '${start.year}', total: range(start, end));
            }(),
        ];
    }
  }

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
      onTap: () => setState(() => _period = period),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkGreen : Colors.grey.shade100,
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
