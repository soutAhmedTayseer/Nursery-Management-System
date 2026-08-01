import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/kid_session.dart';

class ChildSessionCard extends StatelessWidget {
  final KidSession entry;
  final VoidCallback? onTap;
  const ChildSessionCard({super.key, required this.entry, this.onTap});

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = entry.kid.photoUrl;
    final statusColor = entry.isCheckedIn ? AppColors.accentGreen : Colors.grey.shade400;
    // Portrait keeps the same 2-column grid as a narrow landscape window, but
    // each card gets noticeably more width — scale content up so it doesn't
    // look sparse inside the extra space.
    final scale = MediaQuery.orientationOf(context) == Orientation.portrait ? 1.3 : 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
      padding: EdgeInsets.all(20.w * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: statusColor.withValues(alpha: entry.isCheckedIn ? 0.25 : 0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w * scale),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 2)),
                child: CircleAvatar(
                  radius: 30.r * scale,
                  backgroundColor: AppColors.surfaceSage,
                  backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
                  child: photoUrl.isEmpty ? Icon(Icons.person, color: AppColors.accentGreen, size: 24.w * scale) : null,
                ),
              ),
              _buildStatusBadge(scale),
            ],
          ),
          SizedBox(height: 16.h * scale),
          Text(
            entry.kid.fullName,
            style: TextStyle(fontSize: 20.sp * scale, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h * scale),
          Text(
            'session_subscribed_label'.tr(namedArgs: {'plan': entry.planLabel}),
            style: TextStyle(fontSize: 12.sp * scale, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              _buildActionButton(Icons.login, 'session_clock_in'.tr(), entry.isCheckedIn ? Colors.grey.shade200 : AppColors.mintTint, !entry.isCheckedIn, scale),
              SizedBox(width: 8.w * scale),
              _buildActionButton(Icons.logout, 'session_clock_out'.tr(), !entry.isCheckedIn ? Colors.grey.shade200 : AppColors.peachTint, entry.isCheckedIn, scale),
            ],
          )
        ],
      ),
      ),
    );
  }

  Widget _buildStatusBadge(double scale) {
    final color = entry.isCheckedIn ? AppColors.accentGreen : Colors.grey.shade400;
    final elapsed = entry.elapsed;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w * scale, vertical: 6.h * scale),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        children: [
          Text(entry.isCheckedIn ? 'session_checked_in'.tr() : 'session_checked_out'.tr(), style: TextStyle(fontSize: 8.sp * scale, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
          if (entry.isCheckedIn && elapsed != null) ...[
            SizedBox(height: 4.h * scale),
            Row(children: [Icon(Icons.timer_outlined, size: 10.w * scale, color: color), SizedBox(width: 4.w * scale), Text(_formatElapsed(elapsed), style: TextStyle(fontSize: 11.sp * scale, fontWeight: FontWeight.bold, color: color))]),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, bool isActive, double scale) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h * scale),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.w * scale, color: isActive ? Colors.black87 : Colors.grey.shade500),
            SizedBox(width: 4.w * scale),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 10.sp * scale, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey.shade500),
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
