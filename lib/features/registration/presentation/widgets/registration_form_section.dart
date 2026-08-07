import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_palette.dart';

class RegistrationFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  const RegistrationFormSection({
    super.key, required this.title, required this.icon, required this.accentColor, required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: palette.sand, // Off-white/beige color for cards
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: (18 * scale).r,
                backgroundColor: accentColor.withValues(alpha: 0.1),
                child: Icon(icon, color: accentColor, size: (18 * scale).w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: (16 * scale).sp,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          ...children,
        ],
      ),
    );
  }
}
