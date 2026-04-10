import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanHistorySection extends StatelessWidget {
  final String childName;
  const PlanHistorySection({super.key, required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plan History: $childName', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.download, color: Colors.green, size: 16), 
                label: Text('Export Report', style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold))
              )
            ],
          ),
          SizedBox(height: 32.h),
          
          // Table Header
          Row(
            children: [
              Expanded(flex: 2, child: Text('DATE', style: _headerStyle())),
              Expanded(flex: 2, child: Text('OLD PLAN', style: _headerStyle())),
              Expanded(flex: 2, child: Text('NEW PLAN', style: _headerStyle())),
              Expanded(flex: 2, child: Text('CHANGED BY', style: _headerStyle())),
            ],
          ),
          Divider(height: 32.h, color: Colors.grey.shade200),
          
          // Table Rows (Mock Data)
          _buildRow('Oct 12, 2023', 'Hourly', '↑ Monthly', 'Admin Jessica', true),
          _buildRow('Sep 01, 2023', 'New Student', 'Hourly', 'System Auto', false),
          _buildRow('Aug 28, 2023', '—', 'Application Pending', 'Parent Sarah', false, isPending: true),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1);

  Widget _buildRow(String date, String oldPlan, String newPlan, String by, bool isUpgrade, {bool isPending = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(date, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
          Expanded(flex: 2, child: Text(oldPlan, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600))),
          Expanded(flex: 2, child: Text(newPlan, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: isPending ? Colors.orange.shade700 : (isUpgrade ? Colors.green.shade700 : Colors.black87)))),
          Expanded(flex: 2, child: Text(by, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
        ],
      ),
    );
  }
}
