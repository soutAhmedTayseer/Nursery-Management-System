import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/child_session_model.dart';

class ChildSubscriptionCard extends StatelessWidget {
  final ChildSessionModel child;
  final VoidCallback onTap;

  const ChildSubscriptionCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 38.r,
                  backgroundColor: AppColors.background,
                  backgroundImage: child.image.isNotEmpty ? AssetImage(child.image) : null,
                  child: child.image.isEmpty ? Icon(Icons.person, size: 30.w, color: Colors.grey) : null,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'subscription_active_badge'.tr(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Child Name
            Text(
              child.name,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Parent Name (Contextual Info)
            Text(
              'assign_plan_parent_label'.tr(namedArgs: {'lastName': child.name.split(' ').last}),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            // Footer: Plan Info and Price
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F7),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'subscription_card_plan_label'.tr(),
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        child.subscription,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                      ),
                    ],
                  ),
                  Text(
                    '\$240', // يمكن ربطها لاحقاً بالـ Model
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}