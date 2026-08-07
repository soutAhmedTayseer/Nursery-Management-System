import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

/// A titled card grouping related settings. Every section on the screen
/// uses this so headings, padding and dividers stay identical.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.accent,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = accent ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [BoxShadow(color: palette.shadow, blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(color: tint.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(icon, size: 18.w, color: tint),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: palette.textPrimary),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 28.h, color: palette.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One labelled row inside a [SettingsSection]: description on the left,
/// control on the right, stacking on narrow widths so the control never
/// gets squeezed.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: palette.textPrimary)),
            if (description != null) ...[
              SizedBox(height: 2.h),
              Text(description!, style: TextStyle(fontSize: 12.sp, color: palette.textTertiary, height: 1.4)),
            ],
          ],
        );

        if (constraints.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [text, SizedBox(height: 12.h), child],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: text),
            SizedBox(width: 24.w),
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 280.w), child: child),
          ],
        );
      },
    );
  }
}
