import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/responsive/ui_scale.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';
import '../../../subscriptions/presentation/cubit/plans_state.dart';
import '../../../../core/theme/app_palette.dart';

/// Picks a real subscription plan for the child being registered — replaces
/// the old manual timing/fees/hours fields with values derived from the
/// selected `PlanCategory`/`PlanLineItem`.
class PlanPickerSection extends StatelessWidget {
  const PlanPickerSection({super.key, required this.selectedCompositeId, required this.onChanged});

  /// `"<categoryId>:<lineItemId>"`, or null when nothing is picked yet.
  final String? selectedCompositeId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    return BlocBuilder<PlansCubit, PlansState>(
      builder: (context, state) {
        final selected = _findSelected(state.categories, selectedCompositeId);
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: palette.sand, borderRadius: BorderRadius.circular(24.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'registration_label_plan'.tr().toUpperCase(),
                style: TextStyle(fontSize: (10 * scale).sp, fontWeight: FontWeight.w800, color: palette.textTertiary, letterSpacing: 1.1),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(8.r)),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCompositeId,
                    isExpanded: true,
                    hint: Text('registration_hint_plan'.tr(), style: TextStyle(fontSize: (14 * scale).sp, color: palette.textTertiary)),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    items: [
                      for (final category in state.categories)
                        for (final item in category.lineItems)
                          DropdownMenuItem(
                            value: '${category.id}:${item.id}',
                            child: Text('${category.name} · ${item.label} — ${item.price}', style: TextStyle(fontSize: (14 * scale).sp)),
                          ),
                    ],
                    onChanged: onChanged,
                  ),
                ),
              ),
              if (selected != null) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _DerivedStat(label: 'registration_derived_fee'.tr(), value: selected.$2.price)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _DerivedStat(
                        label: 'registration_derived_hours'.tr(),
                        value: selected.$2.hoursPerDay == null
                            ? 'registration_derived_full_day'.tr()
                            : 'registration_derived_hours_value'.tr(namedArgs: {'hours': '${selected.$2.hoursPerDay}'}),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _DerivedStat(
                        label: 'registration_derived_days'.tr(),
                        value: 'registration_derived_days_value'.tr(namedArgs: {'days': '${selected.$2.daysPerCycle}'}),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  (PlanCategory, PlanLineItem)? _findSelected(List<PlanCategory> categories, String? compositeId) {
    if (compositeId == null) return null;
    final parts = compositeId.split(':');
    if (parts.length != 2) return null;
    for (final category in categories) {
      if (category.id != parts[0]) continue;
      for (final item in category.lineItems) {
        if (item.id == parts[1]) return (category, item);
      }
    }
    return null;
  }
}

class _DerivedStat extends StatelessWidget {
  const _DerivedStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: palette.textTertiary, letterSpacing: 0.6)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.brandText)),
      ],
    );
  }
}
