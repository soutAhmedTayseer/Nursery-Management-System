import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/async_state_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../data/models/attendance_day.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';
import '../../../../core/theme/app_palette.dart';

class AttendanceLogTab extends StatelessWidget {
  const AttendanceLogTab({super.key, required this.kid});

  final Kid kid;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(48.r)),
      child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final cubit = context.read<AttendanceCubit>();
          final locale = context.locale.languageCode;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12.h,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat.yMMMM(locale).format(state.month), style: TextStyle(fontFamily: AppFonts.jakarta, fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(
                        'child_profile_attendance_subtitle'.tr(namedArgs: {
                          'days': '${state.presentDaysCount}',
                          'hours': state.totalHours.toStringAsFixed(state.totalHours % 1 == 0 ? 0 : 1),
                        }),
                        style: TextStyle(fontSize: 14.sp, color: palette.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navBtn(context, Icons.chevron_left, cubit.previousMonth),
                      SizedBox(width: 8.w),
                      _navBtn(context, Icons.chevron_right, cubit.nextMonth),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              _buildCalendarGrid(context, state, locale),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: palette.cardMuted,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border(left: BorderSide(color: AppColors.darkGreen, width: 4.w)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 20.w, color: palette.textSecondary),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('child_profile_average_stay_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                            Text('child_profile_average_stay_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: palette.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    Text('${state.averageDailyStay.toStringAsFixed(1)}h', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.brandText)),
                  ],
                ),
              ),
              if (state.totalOvertimeHours > 0) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border(left: BorderSide(color: AppColors.dangerRed, width: 4.w)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 20.w, color: palette.dangerText),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('child_profile_overtime_summary_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                              Text(
                                'child_profile_overtime_summary_subtitle'.tr(namedArgs: {'days': '${state.overtimeDays.length}'}),
                                style: TextStyle(fontSize: 12.sp, color: palette.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text('${state.totalOvertimeHours.toStringAsFixed(1)}h', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.dangerText)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _navBtn(BuildContext context, IconData icon, VoidCallback onTap) {

  final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: palette.divider)),
        child: Icon(icon, size: 18.w, color: palette.textPrimary),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AttendanceState state, String locale) {
    // The calendar is fetched a month at a time now, so it can be loading or
    // fail. An empty grid must never stand in for a month that could not be
    // loaded — this is a record of what a child actually did.
    if (state.isLoading || state.error != null) {
      return SizedBox(
        height: 320.h,
        child: AsyncStateView(
          isLoading: state.isLoading,
          error: state.error,
          isEmpty: false,
          onRetry: () => context.read<AttendanceCubit>().load(),
          emptyMessage: 'state_empty_title'.tr(),
          builder: (_) => const SizedBox.shrink(),
        ),
      );
    }

  final palette = context.palette;
    final weekdayLabels = List.generate(7, (i) => DateFormat.E(locale).format(DateTime(2024, 1, 1 + i))); // Mon..Sun

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                for (final label in weekdayLabels)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: palette.textSecondary.withValues(alpha: 0.4), letterSpacing: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            for (var week = 0; week < state.days.length ~/ 7; week++)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) SizedBox(width: 16.w),
                      Expanded(child: _dayCell(context, state.days[week * 7 + i])),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Overtime days are the ones an admin actually needs to act on, so they
  /// win over the "today" and plain-attended styles and are tappable for
  /// the exact window the child overran.
  Widget _overtimeCell(BuildContext context, AttendanceDay day) {
    final palette = context.palette;
    return InkWell(
      onTap: () => _showOvertimeDetails(context, day),
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        height: 96.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withValues(alpha: palette.stateTint),
          border: Border.all(color: AppColors.dangerRed.withValues(alpha: palette.stateBorderTint), width: 2),
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.dangerText)),
            SizedBox(height: 2.h),
            Text('${_formatHours(day.hours!)}h', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: palette.dangerText)),
            SizedBox(height: 2.h),
            Text(
              'child_profile_overtime_marker'.tr(namedArgs: {'hours': _formatHours(day.overtimeHours)}),
              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: palette.dangerText),
            ),
          ],
        ),
      ),
    );
  }

  void _showOvertimeDetails(BuildContext context, AttendanceDay day) {
    final record = day.record!;
    final window = record.overtimeWindow(day.allowedHours);
    final locale = context.locale.languageCode;
    final palette = context.palette;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          DateFormat.yMMMMd(locale).format(day.date),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(context, 'child_profile_overtime_checked_in'.tr(), _formatTime(record.checkIn, locale)),
            _detailRow(context, 'child_profile_overtime_checked_out'.tr(), record.checkOut == null ? '—' : _formatTime(record.checkOut!, locale)),
            _detailRow(context, 'child_profile_overtime_allowed'.tr(), '${day.allowedHours}h'),
            _detailRow(context, 'child_profile_overtime_actual'.tr(), '${_formatHours(record.hours)}h'),
            const Divider(height: 24),
            if (window != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'child_profile_overtime_window_title'.tr(),
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: palette.dangerText, letterSpacing: 1),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'child_profile_overtime_window_range'.tr(namedArgs: {
                        'from': _formatTime(window.from, locale),
                        'to': _formatTime(window.to, locale),
                        'hours': _formatHours(day.overtimeHours),
                      }),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.dangerText),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('action_close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {

  final palette = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: palette.textSecondary)),
          SizedBox(width: 16.w),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time, String locale) => DateFormat.Hm(locale).format(time);

  Widget _dayCell(BuildContext context, AttendanceDay day) {
  final palette = context.palette;
    final hasAttendance = day.hours != null;

    if (day.hasOvertime) return _overtimeCell(context, day);

    if (day.isToday) {
      return Container(
        height: 96.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.darkGreen, AppColors.brandGradientLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4.h),
            Text('child_profile_today_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      );
    }

    if (!day.inCurrentMonth) {
      return Opacity(
        opacity: 0.2,
        child: Container(
          height: 96.h,
          decoration: BoxDecoration(color: palette.cardMuted.withValues(alpha: palette.isDark ? 0.5 : 0.3), borderRadius: BorderRadius.circular(32.r)),
          alignment: Alignment.center,
          child: Text('${day.date.day}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
        ),
      );
    }

    if (hasAttendance) {
      return Container(
        height: 96.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withValues(alpha: palette.stateTint),
          border: Border.all(color: AppColors.accentGreen.withValues(alpha: palette.stateBorderTint), width: 2),
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.brandText)),
            SizedBox(height: 4.h),
            Text('${_formatHours(day.hours!)}h', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.brandGradientLight)),
          ],
        ),
      );
    }

    // In-month, weekday or weekend with no recorded attendance.
    return Container(
      height: 96.h,
      decoration: BoxDecoration(color: palette.cardMuted, borderRadius: BorderRadius.circular(32.r)),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.textSecondary)),
          if (day.date.weekday < DateTime.saturday) ...[
            SizedBox(height: 4.h),
            Text('child_profile_absent_marker'.tr(), style: TextStyle(fontSize: 10.sp, color: palette.textSecondary)),
          ],
        ],
      ),
    );
  }

  String _formatHours(double hours) => hours % 1 == 0 ? hours.toInt().toString() : hours.toString();
}
