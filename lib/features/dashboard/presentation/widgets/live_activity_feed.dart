import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/schedule_item.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';
import '../screens/schedule_feed_screen.dart';
import '../../../../core/theme/app_palette.dart';

/// Latest-finished / live-now / next-upcoming, styled to match Figma node
/// 1:248's "Live Activity Feed" card exactly (no kid photo asset available,
/// so the thumbnail is an icon tile in the activity's theme color instead).
class LiveActivityFeed extends StatelessWidget {
  const LiveActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, schedule) {
        final nowMinutes = nowInUaeMinutes();
        ScheduleItemModel? finished;
        ScheduleItemModel? active;
        ScheduleItemModel? upcoming;
        for (final item in schedule.items) {
          switch (item.statusAt(nowMinutes)) {
            case ActivityStatus.completed:
              if (finished == null || item.endMinutes > finished.endMinutes) finished = item;
            case ActivityStatus.active:
              active ??= item;
            case ActivityStatus.upcoming:
              if (upcoming == null || item.startMinutes < upcoming.startMinutes) upcoming = item;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('feed_title'.tr(), style: TextStyle(fontSize: (24 * scale).sp, fontWeight: FontWeight.bold, letterSpacing: -0.6, color: palette.textPrimary)),
                Row(
                  children: [
                    Container(width: 8.w, height: 8.w, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkGreen)),
                    SizedBox(width: 8.w),
                    Text('feed_live_now'.tr(), style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.r),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleFeedScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeedCard(item: active, scale: scale, eyebrow: 'schedule_in_session_badge'.tr(), eyebrowColor: AppColors.darkGreen, emptyText: 'feed_none_live'.tr(), badgeIcon: Icons.play_arrow_rounded),
                      SizedBox(height: 20.h),
                      _FeedCard(item: finished, scale: scale, eyebrow: 'feed_completed_label'.tr(), eyebrowColor: palette.textTertiary, emptyText: 'feed_none_finished'.tr(), badgeIcon: Icons.check),
                      SizedBox(height: 20.h),
                      _FeedCard(item: upcoming, scale: scale, eyebrow: 'feed_upcoming_label'.tr(), eyebrowColor: AppColors.amberLabel, emptyText: 'feed_none_upcoming'.tr(), badgeIcon: Icons.schedule),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item, required this.scale, required this.eyebrow, required this.eyebrowColor, required this.emptyText, required this.badgeIcon});

  final ScheduleItemModel? item;
  final double scale;
  final String eyebrow;
  final Color eyebrowColor;
  final String emptyText;
  final IconData badgeIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: item == null
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(emptyText, style: TextStyle(fontSize: (13 * scale).sp, color: palette.textTertiary)),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: (128 * scale).w,
                      height: (128 * scale).w,
                      decoration: BoxDecoration(color: item!.themeColor, borderRadius: BorderRadius.circular(48.r)),
                      child: Icon(item!.icon, size: (48 * scale).w, color: palette.textPrimary),
                    ),
                    Positioned(
                      top: -8.h,
                      right: -8.w,
                      child: Container(
                        width: (28 * scale).w,
                        height: (28 * scale).w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: eyebrowColor, border: Border.all(color: palette.card, width: 2)),
                        child: Icon(badgeIcon, size: (14 * scale).w, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eyebrow, style: TextStyle(fontSize: (14 * scale).sp, fontWeight: FontWeight.bold, letterSpacing: 1.4, color: eyebrowColor)),
                        SizedBox(height: 4.h),
                        Text('${item!.timeSlotLabel.split(' - ').first} - ${item!.title}', style: TextStyle(fontSize: (20 * scale).sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                        if (item!.description.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(item!.description, style: TextStyle(fontSize: (14 * scale).sp, color: palette.textSecondary, height: 1.6)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
