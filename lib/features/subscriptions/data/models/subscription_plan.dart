import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// One priced option inside a [PlanCategory] (e.g. "3 hours / 3 Days — 600 AED").
/// Label/price/badge are admin-entered content, not translation keys.
class PlanLineItem {
  const PlanLineItem({
    required this.id,
    required this.label,
    required this.price,
    this.badgeText,
    this.hoursPerDay,
    this.daysPerCycle = 1,
  });

  final String id;
  final String label;
  final String price;

  /// Optional small pill, e.g. "BEST VALUE". Null renders no badge.
  final String? badgeText;

  /// Hours covered per day. Null means "Full Day" (no fixed hour cap) —
  /// drives Registration's derived hours display instead of a manual entry.
  final int? hoursPerDay;

  /// Days covered by this plan's billing cycle (e.g. 5 for "3 hours / 5 Days").
  final int daysPerCycle;
}

/// A group of priced [lineItems] under one heading (e.g. "Monthly Packages").
/// Admin manages the full catalog as a list of these via [PlansCubit] — no
/// backend endpoint wired yet, so this is in-memory state seeded from
/// [kInitialPlanCategories].
class PlanCategory {
  const PlanCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.themeColor,
    required this.lineItems,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color themeColor;
  final bool isFeatured;
  final List<PlanLineItem> lineItems;

  PlanCategory copyWith({
    String? name,
    IconData? icon,
    Color? themeColor,
    bool? isFeatured,
    List<PlanLineItem>? lineItems,
  }) =>
      PlanCategory(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        themeColor: themeColor ?? this.themeColor,
        isFeatured: isFeatured ?? this.isFeatured,
        lineItems: lineItems ?? this.lineItems,
      );
}

/// Seed catalog mirroring Figma node 181:249 ("Parent - Subscription Plans").
/// [PlansCubit] starts from this list — there is no backend catalog yet.
const List<PlanCategory> kInitialPlanCategories = [
  PlanCategory(
    id: 'monthly_packages',
    name: 'Monthly Packages',
    icon: Icons.calendar_month,
    themeColor: AppColors.darkGreen,
    lineItems: [
      PlanLineItem(id: 'mp_3h_3d', label: '3 hours / 3 Days', price: '600 AED', hoursPerDay: 3, daysPerCycle: 3),
      PlanLineItem(id: 'mp_3h_5d', label: '3 hours / 5 Days', price: '1000 AED', hoursPerDay: 3, daysPerCycle: 5),
      PlanLineItem(id: 'mp_5h_5d', label: '5 hours / 5 Days', price: '1500 AED', hoursPerDay: 5, daysPerCycle: 5),
      PlanLineItem(id: 'mp_8h_5d', label: '8 hours / 5 Days', price: '1750 AED', hoursPerDay: 8, daysPerCycle: 5),
      PlanLineItem(id: 'mp_full_5d', label: 'Full Day / 5 Days', price: '2000 AED', daysPerCycle: 5),
    ],
  ),
  PlanCategory(
    id: 'daily_subscription',
    name: 'Daily Subscription',
    icon: Icons.access_time,
    themeColor: AppColors.amberLabel,
    lineItems: [
      PlanLineItem(id: 'ds_1h', label: 'One Hour', price: '35 AED', hoursPerDay: 1),
      PlanLineItem(id: 'ds_23h', label: '2 / 3 Hours', price: '70 AED', hoursPerDay: 3),
      PlanLineItem(id: 'ds_4h', label: '4 Hours', price: '100 AED', hoursPerDay: 4),
      PlanLineItem(id: 'ds_full', label: 'Full Day', price: '150 AED'),
      PlanLineItem(
        id: 'ds_weekend',
        label: 'Weekend (Sat or Sun) - 5 Hrs',
        price: '50 AED',
        hoursPerDay: 5,
      ),
    ],
  ),
  PlanCategory(
    id: 'weekly_special_offers',
    name: 'Weekly Special Offers',
    icon: Icons.star,
    themeColor: AppColors.darkGreen,
    isFeatured: true,
    lineItems: [
      PlanLineItem(id: 'wso_4d3h', label: '4 Days 3 Hours', price: '250 AED', hoursPerDay: 3, daysPerCycle: 4),
      PlanLineItem(id: 'wso_5d3h', label: '5 Days 3 Hours', price: '300 AED', hoursPerDay: 3, daysPerCycle: 5),
      PlanLineItem(id: 'wso_4dfull', label: '4 Days Full Day', price: '500 AED', daysPerCycle: 4),
      PlanLineItem(id: 'wso_5dfull', label: '5 Days Full Day', price: '600 AED', daysPerCycle: 5),
      PlanLineItem(
        id: 'wso_15dfull',
        label: '15 Days Full Day',
        price: '1500 AED',
        badgeText: 'BEST VALUE',
        daysPerCycle: 15,
      ),
    ],
  ),
];

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
