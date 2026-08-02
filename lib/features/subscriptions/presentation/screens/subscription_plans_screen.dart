import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import '../widgets/plan_category_card.dart';
import '../widgets/plan_category_edit_dialog.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  int _columnsFor(BuildContext context) => switch (context.breakpoint) {
        Breakpoint.compact => 1,
        Breakpoint.medium => 2,
        Breakpoint.expanded => 3,
      };

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceCream,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'subscriptions_screen_title'.tr(),
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'subscriptions_screen_subtitle'.tr(),
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: spacing.xxl),
            BlocBuilder<PlansCubit, PlansState>(
              builder: (context, state) {
                final columns = _columnsFor(context);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - spacing.gutter * (columns - 1)) / columns;
                    return Wrap(
                      spacing: spacing.gutter,
                      runSpacing: spacing.gutter,
                      children: [
                        for (final category in state.categories)
                          SizedBox(
                            width: cardWidth,
                            child: PlanCategoryCard(
                              category: category,
                              onEdit: () => PlanCategoryEditDialog.show(context, category: category),
                            ),
                          ),
                        SizedBox(
                          width: cardWidth,
                          child: _AddCategoryTile(
                            onTap: () => PlanCategoryEditDialog.show(context),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryTile extends StatelessWidget {
  const _AddCategoryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r * 1.5),
      child: Container(
        height: 200.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r * 1.5),
          border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.4), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, size: AppSpacing.iconLg.w, color: AppColors.textSecondary),
            SizedBox(height: 8.h),
            Text('subscriptions_add_category'.tr(), style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
