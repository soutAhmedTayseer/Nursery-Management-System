import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class DailyBreakdownCard extends StatelessWidget {
  final String date;
  final String sessionType;
  final String clockIn;
  final String clockOut;
  final String totalTime;
  final String? overtime; // اختياري عشان لو مفيش أوفرتايم ميظهرش البادج

  const DailyBreakdownCard({
    super.key,
    required this.date,
    required this.sessionType,
    required this.clockIn,
    required this.clockOut,
    required this.totalTime,
    this.overtime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Overtime Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (overtime != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(12.r)),
                  child: Text('Overtime $overtime', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(sessionType, style: TextStyle(fontSize: 12.sp, color: const Color(0xFFB07846), fontWeight: FontWeight.bold)),

          SizedBox(height: 24.h),

          // Times Columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeColumn('CLOCK-IN', Icons.login, clockIn, AppColors.darkGreen),
              _buildDivider(),
              _buildTimeColumn('CLOCK-OUT', Icons.logout, clockOut, const Color(0xFFB07846)),
              _buildDivider(),
              _buildTotalColumn('TOTAL', totalTime),
            ],
          ),
        ],
      ),
    );
  }

  // مساعدة لبناء الأعمدة الداخلية
  Widget _buildTimeColumn(String title, IconData icon, String time, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(icon, size: 16.w, color: iconColor),
            SizedBox(width: 6.w),
            Text(time, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalColumn(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        SizedBox(height: 8.h),
        Text(time, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1.w, height: 30.h, color: Colors.grey.shade200);
  }
}