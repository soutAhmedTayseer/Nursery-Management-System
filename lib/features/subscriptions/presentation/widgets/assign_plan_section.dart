import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/child_session_model.dart';

class AssignPlanSection extends StatelessWidget {
  final ChildSessionModel child;

  const AssignPlanSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('assign_plan_title'.tr(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),
          
          // Child Info Tile
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r, 
                  backgroundImage: AssetImage(child.image),
                  onBackgroundImageError: (_, _) {},
                  child: child.image.isEmpty ? const Icon(Icons.person) : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      Text('assign_plan_parent_label'.tr(namedArgs: {'lastName': child.name.split(' ').last}), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8.r)),
                  child: Text('subscription_active_badge'.tr(), style: TextStyle(fontSize: 9.sp, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          SizedBox(height: 24.h),
          
          Text('assign_plan_current_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.green.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(child.subscription, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                Text('\$240', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          Text('assign_plan_change_plan_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
          SizedBox(height: 8.h),
          // Dropdown Mockup
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('assign_plan_select_new'.tr(), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              label: Text('assign_plan_update_button'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
