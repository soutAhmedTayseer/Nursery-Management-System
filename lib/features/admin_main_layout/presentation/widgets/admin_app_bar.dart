import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class AdminAppBar extends StatelessWidget {
  const AdminAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      color: AppColors.background, // نفس لون خلفية الـ Dashboard الرئيسي
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar
          Expanded(
            flex: 2, // عشان ياخد مساحة أكبر لكن ميفردش للأخر
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search entries, kids or sessions...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          
          Expanded(flex: 1, child: SizedBox()), // مسافة مرنة في النص
          
          // Scan QR Button
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE0B2), // لون برتقالي فاتح
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              elevation: 0,
            ),
            icon: Icon(Icons.qr_code_scanner, color: Colors.orange.shade800, size: 20.w),
            label: Text(
              'Scan QR',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
