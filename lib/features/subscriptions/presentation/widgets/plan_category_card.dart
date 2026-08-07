// lib/features/subscriptions/presentation/widgets/plan_category_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/subscription_plan.dart';
import '../../../../core/theme/app_palette.dart';

/// One category tile on [SubscriptionPlansScreen] / the Financial Dues tab's
/// "Global Plans" grid — an icon+name header, its priced line items, and an
/// edit-pencil that opens [PlanCategoryEditDialog]. Replaces the old
/// single-price [GlobalPlanCard].
class PlanCategoryCard extends StatelessWidget {
  const PlanCategoryCard({
    super.key,
    required this.category,
    this.onEdit,
  });

  final PlanCategory category;

  /// Null renders the card display-only (no edit pencil) — e.g. the
  /// Financial Dues tab's read-only carousel.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final featured = category.isFeatured;
    final radius = BorderRadius.circular(AppSpacing.radiusXl.r * 1.5);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: featured ? category.themeColor.withValues(alpha: 0.04) : Colors.white,
          borderRadius: radius,
          border: Border.all(
            color: featured
                ? category.themeColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            width: featured ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: featured ? 0.06 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top brand stripe, matching the Figma "Monthly Packages"/"Daily
            // Subscription" columns — featured cards use the border+wash
            // treatment above instead, so they skip this bar.
            if (!featured)
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.themeColor, category.themeColor.withValues(alpha: 0.3)],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: category.themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(category.icon, color: category.themeColor, size: AppSpacing.iconMd.w),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
                        ),
                      ),
                      if (onEdit != null)
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(Icons.edit_outlined, size: AppSpacing.iconSm.w, color: palette.textSecondary),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  for (final item in category.lineItems) _LineItemRow(item: item, themeColor: category.themeColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item, required this.themeColor});

  final PlanLineItem item;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(item.label, style: TextStyle(fontSize: 15.sp, color: palette.textPrimary)),
          ),
          if (item.badgeText != null) ...[
            Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(999)),
              child: Text(
                item.badgeText!.toUpperCase(),
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: palette.card, letterSpacing: 0.5),
              ),
            ),
          ],
          Text(item.price, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: themeColor)),
        ],
      ),
    );
  }
}
