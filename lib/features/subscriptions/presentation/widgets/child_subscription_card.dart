import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';

class ChildSubscriptionCard extends StatelessWidget {
  final KidSession child;
  final VoidCallback onTap;

  const ChildSubscriptionCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Portrait keeps the same 2-column grid as a narrow landscape window, but
    // each card gets noticeably more width — scale content up so it doesn't
    // look sparse inside the extra space.
    final scale = MediaQuery.orientationOf(context) == Orientation.portrait ? 1.3 : 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        padding: EdgeInsets.all(24.w * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(3.w * scale),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4), width: 2)),
                  child: CircleAvatar(
                    radius: 34.r * scale,
                    backgroundColor: AppColors.background,
                    backgroundImage: child.kid.photoUrl.isNotEmpty ? NetworkImage(child.kid.photoUrl) : null,
                    child: child.kid.photoUrl.isEmpty ? Icon(Icons.person, size: 28.w * scale, color: Colors.grey) : null,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w * scale, vertical: 6.h * scale),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    'subscription_active_badge'.tr(),
                    style: TextStyle(
                      fontSize: 10.sp * scale,
                      fontWeight: FontWeight.w900,
                      color: AppColors.successDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h * scale),

            // Child Name
            Text(
              child.kid.fullName,
              style: TextStyle(
                fontSize: 22.sp * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h * scale),

            // Parent Name (Contextual Info)
            Text(
              'assign_plan_parent_label'.tr(namedArgs: {'lastName': child.kid.fullName.split(' ').last}),
              style: TextStyle(
                fontSize: 13.sp * scale,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Footer: Plan Info and Price
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h * scale, horizontal: 16.w * scale),
              decoration: BoxDecoration(
                color: AppColors.surfaceMist,
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
                        style: TextStyle(fontSize: 9.sp * scale, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        child.planLabel,
                        style: TextStyle(fontSize: 14.sp * scale, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                      ),
                    ],
                  ),
                  Text(
                    '\$240', // يمكن ربطها لاحقاً بالـ Model
                    style: TextStyle(fontSize: 18.sp * scale, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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