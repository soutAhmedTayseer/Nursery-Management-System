import 'package:flutter/material.dart';

import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// One column of the expanded-breakpoint table view.
class AdaptiveColumn<T> {
  const AdaptiveColumn({
    required this.label,
    required this.cell,
    this.width,
  });

  /// Already-translated header text.
  final String label;
  final Widget Function(T item) cell;

  /// Fixed width in logical pixels; null means the column flexes.
  final double? width;
}

/// A collection that renders as a dense table on wide screens and as the
/// app's existing cards below 1200px.
///
/// Admins scan dozens of rows on a desktop, where a table is the right shape;
/// on a tablet the same table would need horizontal scrolling, so the card
/// layout wins there.
class AdaptiveCollection<T> extends StatelessWidget {
  const AdaptiveCollection({
    super.key,
    required this.items,
    required this.columns,
    required this.cardBuilder,
    this.onRowTap,
  });

  final List<T> items;
  final List<AdaptiveColumn<T>> columns;
  final Widget Function(BuildContext context, T item) cardBuilder;
  final void Function(T item)? onRowTap;

  @override
  Widget build(BuildContext context) {
    return context.isExpanded ? _buildTable(context) : _buildCards(context);
  }

  Widget _buildCards(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.md),
            child: onRowTap == null
                ? cardBuilder(context, item)
                : InkWell(
                    onTap: () => onRowTap!(item),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: cardBuilder(context, item),
                  ),
          ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.xl,
              vertical: spacing.lg,
            ),
            child: Row(
              children: [
                for (final column in columns)
                  _cell(
                    column.width,
                    Text(
                      column.label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.hairline),
          for (final item in items) ...[
            InkWell(
              onTap: onRowTap == null ? null : () => onRowTap!(item),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.lg,
                ),
                child: Row(
                  children: [
                    for (final column in columns)
                      _cell(column.width, column.cell(item)),
                  ],
                ),
              ),
            ),
            const Divider(height: AppSpacing.hairline, color: AppColors.surfaceSmoke),
          ],
        ],
      ),
    );
  }

  Widget _cell(double? width, Widget child) {
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}
