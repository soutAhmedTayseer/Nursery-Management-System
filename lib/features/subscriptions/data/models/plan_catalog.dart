import 'package:flutter/material.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/theme/app_colors.dart';
import 'subscription_plan.dart';

/// Turns the server's flat `List<Plan>` into the two-level catalog the
/// Subscription Plans screen draws.
///
/// The contract deliberately does not store a category's icon or colour
/// (contract §2) — those are design tokens, so they live here. A category with
/// no entry in [_presentation] falls back to a neutral default rather than
/// failing, since an admin can create a category the app has never seen.
class PlanCatalog {
  const PlanCatalog._();

  static const _fallbackIcon = Icons.category_outlined;
  static const _fallbackColor = AppColors.darkGreen;

  static const Map<String, (IconData, Color)> _presentation = {
    'Monthly Packages': (Icons.calendar_month, AppColors.darkGreen),
    'Daily Subscription': (Icons.access_time, AppColors.amberLabel),
    'Weekly Special Offers': (Icons.star, AppColors.darkGreen),
  };

  /// Groups [plans] by their `category` string, preserving first-seen order so
  /// the catalog does not reshuffle between loads.
  static List<PlanCategory> group(List<Plan> plans) {
    final byCategory = <String, List<Plan>>{};
    for (final plan in plans) {
      byCategory.putIfAbsent(plan.category, () => []).add(plan);
    }

    return [
      for (final entry in byCategory.entries)
        PlanCategory(
          id: _slug(entry.key),
          name: entry.key,
          icon: _presentation[entry.key]?.$1 ?? _fallbackIcon,
          themeColor: _presentation[entry.key]?.$2 ?? _fallbackColor,
          // A category is featured when any plan in it is.
          isFeatured: entry.value.any((p) => p.isFeatured),
          lineItems: [for (final plan in entry.value) toLineItem(plan)],
        ),
    ];
  }

  static PlanLineItem toLineItem(Plan plan) => PlanLineItem(
        id: plan.id,
        label: plan.name,
        price: formatPrice(plan.price, plan.currency),
        badgeText: plan.badgeText,
        hoursPerDay: plan.hoursPerDay?.round(),
        daysPerCycle: plan.daysPerCycle,
      );

  /// Rebuilds the wire model from an edited line item. [category] comes from
  /// the [PlanCategory] the item sits under, which the flat model needs back.
  static Plan toPlan(
    PlanLineItem item, {
    required String category,
    required String currency,
    required bool isFeatured,
    bool active = true,
  }) =>
      Plan(
        id: item.id,
        name: item.label,
        category: category,
        // The screen never edits a package total, only the per-day figure.
        hoursIncluded: (item.hoursPerDay ?? 0) * item.daysPerCycle.toDouble(),
        hoursPerDay: item.hoursPerDay?.toDouble(),
        daysPerCycle: item.daysPerCycle,
        price: parsePrice(item.price),
        currency: currency,
        badgeText: item.badgeText,
        isFeatured: isFeatured,
        active: active,
      );

  /// `1200, "AED"` -> `"1200 AED"`, matching the format the screen already
  /// renders. Price is numeric on the wire; this is the presentation step.
  static String formatPrice(double price, String currency) {
    final rounded = price.roundToDouble() == price
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '$rounded $currency';
  }

  /// Reads a number back out of an admin-entered price string, tolerating a
  /// currency code, thousands separators and stray spaces (`"AED 1,200"`,
  /// `"1200 AED"`, `"1200"`). Returns 0 when nothing numeric is present rather
  /// than throwing — the field is free text and the server validates anyway.
  static double parsePrice(String raw) {
    final digits = RegExp(r'[\d.]+').allMatches(raw.replaceAll(',', ''));
    if (digits.isEmpty) return 0;
    return double.tryParse(digits.first.group(0)!) ?? 0;
  }

  static String _slug(String category) =>
      category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}
