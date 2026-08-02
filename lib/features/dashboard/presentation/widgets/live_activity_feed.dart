import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/overview_state.dart';

/// Real recent check-in/check-out events, most recent first — replaces the
/// old hardcoded "Upcoming Activity"/"Past Activity" mock, since there's no
/// activities-scheduling feature behind those yet.
class LiveActivityFeed extends StatelessWidget {
  const LiveActivityFeed({super.key, required this.events});

  final List<ActivityEvent> events;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header — stays put; only the content below scrolls.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('feed_title'.tr(), style: TextStyle(fontSize: (22 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                CircleAvatar(radius: (4 * scale).r, backgroundColor: Colors.green),
                SizedBox(width: 8.w),
                Text('feed_live_now'.tr(), style: TextStyle(fontSize: (10 * scale).sp, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),

        Expanded(
          child: events.isEmpty
              ? Center(child: Text('feed_empty'.tr(), style: TextStyle(fontSize: (13 * scale).sp, color: Colors.grey.shade500)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < events.length; i++) ...[
                        _buildEventTile(events[i], scale, emphasized: i == 0),
                        if (i != events.length - 1) SizedBox(height: 12.h),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEventTile(ActivityEvent event, double scale, {required bool emphasized}) {
    final ago = DateTime.now().difference(event.at);
    final agoText = ago.inMinutes < 60 ? 'feed_minutes_ago'.tr(namedArgs: {'n': '${ago.inMinutes}'}) : 'feed_hours_ago'.tr(namedArgs: {'n': '${ago.inHours}'});
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: emphasized ? Colors.white : AppColors.surfaceSmoke,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: emphasized ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))] : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: (20 * scale).r,
            backgroundColor: AppColors.successTint,
            child: Icon(Icons.login, color: AppColors.successDark, size: (18 * scale).w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('feed_checked_in'.tr(namedArgs: {'name': event.kidName}), style: TextStyle(fontSize: (14 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 4.h),
                Text(agoText, style: TextStyle(fontSize: (11 * scale).sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
