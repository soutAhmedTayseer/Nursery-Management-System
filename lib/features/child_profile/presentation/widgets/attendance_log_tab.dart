import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../data/models/attendance_day.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';

class AttendanceLogTab extends StatelessWidget {
  const AttendanceLogTab({super.key, required this.kid});

  final Kid kid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(48.r)),
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
                      Text(DateFormat.yMMMM(locale).format(state.month), style: TextStyle(fontFamily: AppFonts.jakarta, fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(
                        'child_profile_attendance_subtitle'.tr(namedArgs: {
                          'days': '${state.presentDaysCount}',
                          'hours': state.totalHours.toStringAsFixed(state.totalHours % 1 == 0 ? 0 : 1),
                        }),
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navBtn(Icons.chevron_left, cubit.previousMonth),
                      SizedBox(width: 8.w),
                      _navBtn(Icons.chevron_right, cubit.nextMonth),
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
                  color: AppColors.surfaceCream,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border(left: BorderSide(color: AppColors.darkGreen, width: 4.w)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 20.w, color: AppColors.textSecondary),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('child_profile_average_stay_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('child_profile_average_stay_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    Text('${state.averageDailyStay.toStringAsFixed(1)}h', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              _buildQrSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQrSection() {
    final payload = kid.qrPayload;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: AppColors.surfaceCream, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            child: payload == null
                ? Icon(Icons.qr_code_2, size: 48.w, color: Colors.grey.shade300)
                : QrImageView(data: payload, backgroundColor: Colors.white),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('child_profile_qr_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 4.h),
                Text('child_profile_qr_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
        child: Icon(icon, size: 18.w, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AttendanceState state, String locale) {
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
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.4), letterSpacing: 0.5),
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
                      Expanded(child: _dayCell(state.days[week * 7 + i])),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _dayCell(AttendanceDay day) {
    final hasAttendance = day.hours != null;

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
          decoration: BoxDecoration(color: AppColors.surfaceCream.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(32.r)),
          alignment: Alignment.center,
          child: Text('${day.date.day}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
      );
    }

    if (hasAttendance) {
      return Container(
        height: 96.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.darkGreen.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.2), width: 2),
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            SizedBox(height: 4.h),
            Text('${_formatHours(day.hours!)}h', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.brandGradientLight)),
          ],
        ),
      );
    }

    // In-month, weekday or weekend with no recorded attendance.
    return Container(
      height: 96.h,
      decoration: BoxDecoration(color: AppColors.calendarMuted, borderRadius: BorderRadius.circular(32.r)),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${day.date.day}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          if (day.date.weekday < DateTime.saturday) ...[
            SizedBox(height: 4.h),
            Text('child_profile_absent_marker'.tr(), style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
          ],
        ],
      ),
    );
  }

  String _formatHours(double hours) => hours % 1 == 0 ? hours.toInt().toString() : hours.toString();
}
