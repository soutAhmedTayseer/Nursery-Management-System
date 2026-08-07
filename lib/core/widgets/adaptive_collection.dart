import 'package:flutter/material.dart';

import '../responsive/breakpoints.dart';
import '../theme/app_spacing.dart';
import '../../core/theme/app_palette.dart';

/// Horizontal placement of a column's header and its cells. Both use the
/// same value, so a header always sits over the data it describes.
enum AdaptiveColumnAlign { start, center, end }

/// One column of the expanded-breakpoint table view.
class AdaptiveColumn<T> {
  const AdaptiveColumn({
    required this.label,
    required this.cell,
    this.width,
    this.align = AdaptiveColumnAlign.start,
  });

  /// Already-translated header text.
  final String label;
  final Widget Function(T item) cell;

  /// Fixed width in logical pixels; null means the column flexes.
  final double? width;

  final AdaptiveColumnAlign align;

  Alignment get _alignment => switch (align) {
        AdaptiveColumnAlign.start => AlignmentDirectional.centerStart.resolve(TextDirection.ltr),
        AdaptiveColumnAlign.center => Alignment.center,
        AdaptiveColumnAlign.end => AlignmentDirectional.centerEnd.resolve(TextDirection.ltr),
      };

  TextAlign get _textAlign => switch (align) {
        AdaptiveColumnAlign.start => TextAlign.start,
        AdaptiveColumnAlign.center => TextAlign.center,
        AdaptiveColumnAlign.end => TextAlign.end,
      };
}

/// Breaks a multi-word header over two balanced lines, so "OVERTIME HOURS"
/// stacks instead of stretching the column (and colliding with its
/// neighbour). Single words are left alone.
String stackedHeaderLabel(String label) {
  final words = label.trim().split(RegExp(r'\s+'));
  if (words.length < 2) return label;

  // Split where the two lines come out closest in length.
  var bestSplit = 1;
  var bestDelta = -1;
  for (var i = 1; i < words.length; i++) {
    final left = words.sublist(0, i).join(' ').length;
    final right = words.sublist(i).join(' ').length;
    final delta = (left - right).abs();
    if (bestDelta == -1 || delta < bestDelta) {
      bestDelta = delta;
      bestSplit = i;
    }
  }
  return '${words.sublist(0, bestSplit).join(' ')}\n${words.sublist(bestSplit).join(' ')}';
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
    this.rowBackgroundColor,
    this.rowBorderColor,
  });

  final List<T> items;
  final List<AdaptiveColumn<T>> columns;
  final Widget Function(BuildContext context, T item) cardBuilder;
  final void Function(T item)? onRowTap;

  /// Per-row background for the expanded-breakpoint table (e.g. highlighting
  /// a flagged record). Null/no match falls back to the default white row.
  final Color? Function(T item)? rowBackgroundColor;

  /// Per-row left accent border for the expanded-breakpoint table, paired
  /// with [rowBackgroundColor] for a highlighted-row treatment.
  final Color? Function(T item)? rowBorderColor;

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
  final palette = context.palette;
    final spacing = AppSpacing.of(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: spacing.md,
              children: [
                for (final column in columns)
                  _cell(
                    column,
                    Text(
                      stackedHeaderLabel(column.label),
                      textAlign: column._textAlign,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.hairline),
          for (final item in items) ...[
            Container(
              decoration: BoxDecoration(
                color: rowBackgroundColor?.call(item),
                border: _leftBorder(rowBorderColor?.call(item)),
              ),
              child: InkWell(
                onTap: onRowTap == null ? null : () => onRowTap!(item),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xl,
                    vertical: spacing.lg,
                  ),
                  child: Row(
                    spacing: spacing.md,
                    children: [
                      for (final column in columns)
                        _cell(column, column.cell(item)),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: AppSpacing.hairline, color: palette.divider),
          ],
        ],
      ),
    );
  }

  Border? _leftBorder(Color? color) => color == null ? null : Border(left: BorderSide(color: color, width: 4));

  /// Wraps a header or cell so it honours its column's width and alignment —
  /// the header and the data below it always resolve to the same box.
  Widget _cell(AdaptiveColumn<T> column, Widget child) {
    final aligned = Align(alignment: column._alignment, child: child);
    return column.width == null
        ? Expanded(child: aligned)
        : SizedBox(width: column.width, child: aligned);
  }
}
