import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Widget? trendWidget;
  final IconData? watermarkIcon;

  const FinanceStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.trendWidget,
    this.watermarkIcon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(32.r);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: radius),
        child: Stack(
          children: [
            if (watermarkIcon != null)
              Positioned(
                right: -16.w,
                bottom: -16.h,
                child: Icon(watermarkIcon, size: 96.w, color: Colors.white.withValues(alpha: 0.1)),
              ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(width: 4.w),
                      Text('finance_currency_aed'.tr(), style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
                    ],
                  ),
                  if (trendWidget != null) ...[
                    SizedBox(height: 12.h),
                    trendWidget!,
                  ],
                  SizedBox(height: 24.h),
                  Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.white60, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
