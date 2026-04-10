import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Widget? trendWidget;

  const FinanceStatCard({
    super.key, 
    required this.title, 
    required this.value, 
    required this.subtitle, 
    required this.color, 
    this.trendWidget
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(), 
            style: TextStyle(
              fontSize: 10.sp, 
              color: Colors.white70, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1
            )
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value, 
                style: TextStyle(
                  fontSize: 28.sp, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white
                )
              ),
              SizedBox(width: 4.w),
              Text(
                'AED', 
                style: TextStyle(fontSize: 12.sp, color: Colors.white70)
              ),
            ],
          ),
          if (trendWidget != null) ...[
            SizedBox(height: 12.h),
            trendWidget!
          ],
          const Spacer(),
          Text(
            subtitle, 
            style: TextStyle(
              fontSize: 11.sp, 
              color: Colors.white60, 
              height: 1.4
            )
          ),
        ],
      ),
    );
  }
}
