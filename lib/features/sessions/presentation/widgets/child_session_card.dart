import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/kid_session.dart';

class ChildSessionCard extends StatelessWidget {
  final KidSession entry;
  const ChildSessionCard({super.key, required this.entry});

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = entry.kid.photoUrl;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
                child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              _buildStatusBadge(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            entry.kid.fullName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'session_subscribed_label'.tr(namedArgs: {'plan': entry.planLabel}),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              _buildActionButton(Icons.login, 'session_clock_in'.tr(), entry.isCheckedIn ? Colors.grey.shade200 : AppColors.mintTint, !entry.isCheckedIn),
              SizedBox(width: 8.w),
              _buildActionButton(Icons.logout, 'session_clock_out'.tr(), !entry.isCheckedIn ? Colors.grey.shade200 : AppColors.peachTint, entry.isCheckedIn),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = entry.isCheckedIn ? AppColors.accentGreen : Colors.grey.shade400;
    final elapsed = entry.elapsed;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          Text(entry.isCheckedIn ? 'session_checked_in'.tr() : 'session_checked_out'.tr(), style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
          if (entry.isCheckedIn && elapsed != null) ...[
            SizedBox(height: 4.h),
            Row(children: [Icon(Icons.timer_outlined, size: 10.w, color: color), SizedBox(width: 4.w), Text(_formatElapsed(elapsed), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color))]),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, bool isActive) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.w, color: isActive ? Colors.black87 : Colors.grey.shade500),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
