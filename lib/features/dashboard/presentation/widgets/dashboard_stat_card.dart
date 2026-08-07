import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_palette.dart';

/// Design height of every dashboard stat card, before `.h` scaling. Sized
/// for the tallest content a card carries (two-line subtitle + a footer);
/// keeping it a single constant is what makes the whole strip uniform.
const double kDashboardStatCardHeight = 244;

/// Width bounds for a dashboard stat card, before `uiScale`. The floor is
/// wide enough that a long title and a large figure both sit comfortably
/// instead of being squeezed toward overflow.
const double kDashboardStatCardMinWidth = 300;
const double kDashboardStatCardMaxWidth = 440;

/// One figure on the dashboard's stats strip.
///
/// Expects a **bounded height** from its parent (see [kDashboardStatCardHeight])
/// — it pins its footer to the bottom with a [Spacer] so a row of cards
/// lines up regardless of how much text each one carries.
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String subtitle;
  final IconData icon;
  final Color themeColor;

  /// Optional footer (progress bar, drill-in link). Cards that are just a
  /// figure omit it.
  final Widget? bottomWidget;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    this.bottomWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    final card = Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Title & Icon). The title takes the space the icon
          // doesn't — long titles ellipsize instead of overflowing the row.
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (12 * scale).sp,
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              CircleAvatar(
                radius: (18 * scale).r,
                backgroundColor: themeColor,
                child: Icon(icon, color: palette.card, size: (18 * scale).w),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Value + unit. A large figure (a five-digit revenue total) would
          // outgrow a narrow card, so scale the pair down to fit rather than
          // overflow it.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: (48 * scale).sp,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                    height: 1,
                  ),
                ),
                if (unit != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    unit!,
                    style: TextStyle(
                      fontSize: (16 * scale).sp,
                      fontWeight: FontWeight.bold,
                      color: palette.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: (14 * scale).sp,
              color: palette.textTertiary,
            ),
          ),

          // Absorbs the leftover height so every card's footer sits on the
          // same baseline, however long its subtitle ran.
          const Spacer(),
          ?bottomWidget,
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(32.r),
      onTap: onTap,
      child: card,
    );
  }
}
