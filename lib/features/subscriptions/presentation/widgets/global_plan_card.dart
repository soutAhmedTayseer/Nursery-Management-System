import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalPlanCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final IconData icon;
  final Color themeColor;
  final bool isSolid;

  const GlobalPlanCard({
    super.key, required this.title, required this.duration, required this.price, 
    required this.icon, required this.themeColor, this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isSolid ? themeColor : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: isSolid ? null : Border(bottom: BorderSide(color: themeColor, width: 8.h)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: isSolid ? Colors.white.withOpacity(0.2) : themeColor.withOpacity(0.1),
                child: Icon(icon, color: isSolid ? Colors.white : themeColor, size: 16.w),
              ),
              Icon(Icons.edit_outlined, color: isSolid ? Colors.white70 : Colors.grey.shade400, size: 14.w),
            ],
          ),
          SizedBox(height: 24.h),
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isSolid ? Colors.white : Colors.black87)),
          Text(duration, style: TextStyle(fontSize: 11.sp, color: isSolid ? Colors.white70 : Colors.grey.shade500)),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: isSolid ? Colors.white : Colors.black87)),
              Text(' /mo', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: isSolid ? Colors.white70 : Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
