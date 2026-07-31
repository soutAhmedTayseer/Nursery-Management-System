import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Grey placeholder rows shown while a collection loads.
///
/// Deliberately animation-free: the admin dashboard runs on tablets and low-end
/// browser windows, and a shimmer on every list is more repaint cost than the
/// polish is worth.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 6, this.rowHeight = 64});
  // 64 is the seed-data card height; callers override per collection.

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Column(
      children: List.generate(
        rows,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: spacing.md),
          child: Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceSmoke,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
