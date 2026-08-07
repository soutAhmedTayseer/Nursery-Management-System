import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/kid_photo_provider.dart';
import '../../data/models/kid_session.dart';
import '../../../../core/theme/app_palette.dart';

/// Matches Figma node 1:807's child card: photo with one squared corner,
/// a "CHECKED-IN"/"CHECKED-OUT" pill + elapsed timer, name, plan line, and
/// two clock buttons (only the applicable one is enabled).
class ChildSessionCard extends StatelessWidget {
  final KidSession entry;
  final VoidCallback? onTap;
  final VoidCallback? onClockIn;
  final VoidCallback? onClockOut;

  const ChildSessionCard({super.key, required this.entry, this.onTap, this.onClockIn, this.onClockOut});

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final photoUrl = entry.kid.photoUrl;
    final isCheckedIn = entry.isCheckedIn;
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
          color: palette.card,
          borderRadius: BorderRadius.circular(28.r),
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
                  width: 56.w * scale,
                  height: 56.w * scale,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSage,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                      bottomLeft: Radius.circular(6.r),
                    ),
                    image: photoUrl.isEmpty ? null : DecorationImage(image: kidPhotoProvider(photoUrl), fit: BoxFit.cover),
                  ),
                  child: photoUrl.isEmpty ? Icon(Icons.person, color: AppColors.accentGreen, size: 24.w * scale) : null,
                ),
                _buildStatusBadge(context, scale),
              ],
            ),
            SizedBox(height: 16.h * scale),
            Text(
              entry.kid.fullName,
              style: TextStyle(fontSize: 20.sp * scale, fontWeight: FontWeight.bold, color: palette.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h * scale),
            // Plan names run long ("Monthly Packages · 3 hours / 5 Days") and
            // a single ellipsized line hid the part that actually
            // distinguishes them, so let it wrap.
            Text(
              'session_subscribed_label'.tr(namedArgs: {'plan': entry.planLabel}),
              style: TextStyle(fontSize: 12.sp * scale, color: palette.textTertiary, fontWeight: FontWeight.w500, height: 1.35),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _buildActionButton(context, Icons.login, 'session_clock_in'.tr(), isCheckedIn ? Colors.grey.shade200 : AppColors.mintTint, !isCheckedIn, scale, isCheckedIn ? null : onClockIn),
                SizedBox(width: 8.w * scale),
                _buildActionButton(context, Icons.logout, 'session_clock_out'.tr(), !isCheckedIn ? Colors.grey.shade200 : AppColors.peachTint, isCheckedIn, scale, isCheckedIn ? onClockOut : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, double scale) {

  final palette = context.palette;
    final isCheckedIn = entry.isCheckedIn;
    final color = isCheckedIn ? AppColors.accentGreen : palette.textTertiary;
    final bgColor = isCheckedIn ? AppColors.accentGreen.withValues(alpha: 0.1) : palette.chip;
    final elapsed = entry.elapsed;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w * scale, vertical: 6.h * scale),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        children: [
          Text(isCheckedIn ? 'session_checked_in'.tr() : 'session_checked_out'.tr(), style: TextStyle(fontSize: 9.sp * scale, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
          if (isCheckedIn && elapsed != null) ...[
            SizedBox(height: 4.h * scale),
            Row(children: [Icon(Icons.timer_outlined, size: 10.w * scale, color: AppColors.amberLabel), SizedBox(width: 4.w * scale), Text(_formatElapsed(elapsed), style: TextStyle(fontSize: 11.sp * scale, fontWeight: FontWeight.bold, color: AppColors.amberLabel))]),
          ] else if (!isCheckedIn) ...[
            SizedBox(height: 4.h * scale),
            Text('--h --m', style: TextStyle(fontSize: 11.sp * scale, fontWeight: FontWeight.bold, color: palette.textTertiary)),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color bgColor, bool isActive, double scale, VoidCallback? onTap) {

  final palette = context.palette;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h * scale),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16.r)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.w * scale, color: isActive ? Colors.black87 : palette.textTertiary),
              SizedBox(width: 4.w * scale),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10.sp * scale, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : palette.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
