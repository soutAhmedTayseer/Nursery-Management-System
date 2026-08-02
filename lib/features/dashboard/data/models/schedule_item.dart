import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum ActivityStatus { completed, active, upcoming }

/// One block of the nursery's daily routine. [startMinutes]/[endMinutes] are
/// minutes since midnight (UAE local time) — [ActivityStatus] is derived from
/// them at read time via [statusAt], never stored, so it always reflects the
/// current time.
class ScheduleItemModel {
  const ScheduleItemModel({
    required this.id,
    required this.startMinutes,
    required this.endMinutes,
    required this.title,
    this.description = '',
    required this.icon,
    required this.themeColor,
  });

  final String id;
  final int startMinutes;
  final int endMinutes;
  final String title;
  final String description;
  final IconData icon;
  final Color themeColor;

  ActivityStatus statusAt(int nowMinutes) {
    if (nowMinutes >= endMinutes) return ActivityStatus.completed;
    if (nowMinutes >= startMinutes) return ActivityStatus.active;
    return ActivityStatus.upcoming;
  }

  String get timeSlotLabel => '${_formatMinutes(startMinutes)} - ${_formatMinutes(endMinutes)}';

  ScheduleItemModel copyWith({
    int? startMinutes,
    int? endMinutes,
    String? title,
    String? description,
    IconData? icon,
    Color? themeColor,
  }) =>
      ScheduleItemModel(
        id: id,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
        title: title ?? this.title,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        themeColor: themeColor ?? this.themeColor,
      );
}

String _formatMinutes(int minutes) {
  final hour24 = (minutes ~/ 60) % 24;
  final minute = minutes % 60;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '${hour12.toString()}:${minute.toString().padLeft(2, '0')} $period';
}

/// Current time in the UAE (UTC+4, no daylight saving), as minutes since
/// midnight — used to derive each item's live [ActivityStatus].
int nowInUaeMinutes() {
  final uaeNow = DateTime.now().toUtc().add(const Duration(hours: 4));
  return uaeNow.hour * 60 + uaeNow.minute;
}

final List<ScheduleItemModel> kInitialSchedule = [
  ScheduleItemModel(
    id: '1',
    startMinutes: 6 * 60 + 30,
    endMinutes: 9 * 60,
    title: 'Greeting the kids (Free play)',
    icon: Icons.child_care,
    themeColor: AppColors.schedulePastelAmber,
  ),
  ScheduleItemModel(
    id: '2',
    startMinutes: 9 * 60,
    endMinutes: 10 * 60,
    title: 'Breakfast',
    icon: Icons.free_breakfast_outlined,
    themeColor: AppColors.schedulePastelPeach,
  ),
  ScheduleItemModel(
    id: '3',
    startMinutes: 10 * 60,
    endMinutes: 11 * 60,
    title: 'Learning time (ABC, 123, Colors)',
    icon: Icons.menu_book_rounded,
    themeColor: AppColors.schedulePastelPink,
  ),
  ScheduleItemModel(
    id: '4',
    startMinutes: 11 * 60,
    endMinutes: 13 * 60,
    title: 'Arts & Crafts',
    icon: Icons.palette_outlined,
    themeColor: AppColors.schedulePastelRose,
  ),
  ScheduleItemModel(
    id: '5',
    startMinutes: 13 * 60,
    endMinutes: 14 * 60,
    title: 'Sensory play (Water, sand, dough)',
    icon: Icons.water_drop_outlined,
    themeColor: AppColors.schedulePastelBlush,
  ),
  ScheduleItemModel(
    id: '6',
    startMinutes: 14 * 60,
    endMinutes: 15 * 60,
    title: 'Free play + Dancing',
    icon: Icons.music_note_outlined,
    themeColor: AppColors.schedulePastelSage,
  ),
  ScheduleItemModel(
    id: '7',
    startMinutes: 15 * 60,
    endMinutes: 16 * 60,
    title: 'Lunch + Calm time',
    icon: Icons.restaurant_outlined,
    themeColor: AppColors.schedulePastelMint,
  ),
  ScheduleItemModel(
    id: '8',
    startMinutes: 16 * 60,
    endMinutes: 17 * 60,
    title: 'Puzzle / Blocks / Drawing',
    icon: Icons.extension_outlined,
    themeColor: AppColors.schedulePastelGreen,
  ),
  ScheduleItemModel(
    id: '9',
    startMinutes: 17 * 60,
    endMinutes: 19 * 60,
    title: 'Free play',
    icon: Icons.sports_esports_outlined,
    themeColor: AppColors.schedulePastelDeepGreen,
  ),
];
