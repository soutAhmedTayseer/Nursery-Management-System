import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The nursery's fixed set of global plans. No backend endpoint for plans
/// yet, so this is a hardcoded catalog rather than fetched data — titles/
/// durations stay as translation keys so callers still localize them.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.titleKey,
    required this.durationKey,
    required this.price,
    required this.icon,
    required this.themeColor,
    this.isSolid = false,
    this.priceSuffixKey = 'global_plan_per_month_suffix',
    this.iconAsset,
  });

  final String id;
  final String titleKey;
  final String durationKey;
  final String price;
  final IconData icon;
  final Color themeColor;
  final bool isSolid;
  final String priceSuffixKey;

  /// Figma-exported SVG badge (bg + glyph baked together) for the
  /// GlobalPlanCard icon. Null falls back to [icon] on a themeColor-tinted
  /// container — used for the solid Winter Camp card, whose translucent
  /// white badge doesn't survive standalone SVG export.
  final String? iconAsset;
}

const List<SubscriptionPlan> kSubscriptionPlans = [
  SubscriptionPlan(
    id: 'monthly',
    titleKey: 'subscriptions_plan_monthly',
    durationKey: 'subscriptions_plan_monthly_duration',
    price: '\$240',
    icon: Icons.calendar_month,
    themeColor: AppColors.darkGreen,
    iconAsset: 'assets/icons/subscriptions/plan_monthly.svg',
  ),
  SubscriptionPlan(
    id: 'weekly',
    titleKey: 'subscriptions_plan_weekly_focus',
    durationKey: 'subscriptions_plan_weekly_duration',
    price: '\$450',
    icon: Icons.calendar_today,
    themeColor: AppColors.subscriptionBrown,
    iconAsset: 'assets/icons/subscriptions/plan_weekly.svg',
  ),
  SubscriptionPlan(
    id: 'hourly',
    titleKey: 'subscriptions_plan_hourly',
    durationKey: 'subscriptions_plan_hourly_duration',
    price: '\$18',
    icon: Icons.access_time,
    themeColor: AppColors.amberLabel,
    priceSuffixKey: 'global_plan_per_hour_suffix',
    iconAsset: 'assets/icons/subscriptions/plan_hourly.svg',
  ),
  SubscriptionPlan(
    id: 'winter_camp',
    titleKey: 'subscriptions_plan_winter_camp',
    durationKey: 'subscriptions_plan_winter_duration',
    price: '\$1,200',
    icon: Icons.holiday_village,
    themeColor: AppColors.forestGreen,
    isSolid: true,
    priceSuffixKey: 'global_plan_per_package_suffix',
  ),
];

SubscriptionPlan? findPlanById(String? id) {
  if (id == null) return null;
  for (final plan in kSubscriptionPlans) {
    if (plan.id == id) return plan;
  }
  return null;
}

/// One row of a child's plan-change log.
class PlanChangeEntry {
  const PlanChangeEntry({
    required this.date,
    required this.oldPlanLabel,
    required this.newPlanLabel,
    required this.changedBy,
  });

  final DateTime date;
  final String oldPlanLabel;
  final String newPlanLabel;
  final String changedBy;
}
