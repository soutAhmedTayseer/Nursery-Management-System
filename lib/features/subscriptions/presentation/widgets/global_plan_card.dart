import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GlobalPlanCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final IconData icon;
  final Color themeColor;
  final bool isSolid;
  final String priceSuffixKey;
  final String? iconAsset;

  const GlobalPlanCard({
    super.key,
    required this.title,
    required this.duration,
    required this.price,
    required this.icon,
    required this.themeColor,
    this.isSolid = false,
    this.priceSuffixKey = 'global_plan_per_month_suffix',
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
      decoration: BoxDecoration(
        color: isSolid ? themeColor : Colors.white,
        borderRadius: BorderRadius.circular(48.r),
        border: isSolid ? null : Border(bottom: BorderSide(color: themeColor, width: 4.h)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (iconAsset != null)
                SvgPicture.asset(iconAsset!, width: 34.w, height: 36.w)
              else
                Container(
                  width: 34.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: isSolid ? Colors.white.withValues(alpha: 0.2) : themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: isSolid ? Colors.white : themeColor, size: 16.w),
                ),
              SvgPicture.asset(
                isSolid ? 'assets/icons/subscriptions/edit_pencil_light.svg' : 'assets/icons/subscriptions/edit_pencil.svg',
                width: 10.5.w,
                height: 10.5.w,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isSolid ? Colors.white : Colors.black87)),
          SizedBox(height: 2.h),
          Text(duration, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: isSolid ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade500)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: isSolid ? Colors.white : Colors.black87)),
              Text(priceSuffixKey.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: isSolid ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
