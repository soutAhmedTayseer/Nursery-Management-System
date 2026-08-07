import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../sessions/data/models/kid_session.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';

String _csvField(String value) {
  final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}

/// Every month's [AttendanceState] from the child's join month through the
/// currently-viewed month, generated via the same deterministic mock cubit
/// the Attendance Log tab uses — there's no backend endpoint for historical
/// attendance yet, so this recreates each month's calendar rather than
/// storing a separate copy of it.
List<AttendanceState> _fullAttendanceHistory(String kidId, DateTime joinDate, DateTime throughMonth) {
  final cubit = AttendanceCubit(kidId);
  final states = <AttendanceState>[];
  var cursor = DateTime(throughMonth.year, throughMonth.month);
  final start = DateTime(joinDate.year, joinDate.month);
  while (!cursor.isBefore(start)) {
    states.add(cubit.state);
    if (cursor == start) break;
    cubit.previousMonth();
    cursor = DateTime(cursor.year, cursor.month - 1);
  }
  cubit.close();
  return states;
}

/// Exports the child's full profile: info, allergies, emergency contact,
/// current plan, complete attendance log (every month since joining), and
/// full plan/financial-dues history — as one CSV.
Future<void> exportChildProfileCsv({
  required BuildContext context,
  required KidSession childData,
  required String currentPlanTitle,
  required String currentPlanPrice,
  required List<PlanChangeEntry> planHistory,
  required AttendanceState attendance,
}) async {
  final kid = childData.kid;
  final buffer = StringBuffer()
    ..writeln('Child Name,Date of Birth,Allergies,Emergency Contact,Emergency Phone,Current Plan,Plan Price')
    ..writeln(
      '${_csvField(kid.fullName)},${kid.dateOfBirth.toIso8601String().split('T').first},'
      '${_csvField(kid.allergies ?? '')},${_csvField(kid.emergencyContactName)},'
      '${_csvField(kid.emergencyContactPhone)},${_csvField(currentPlanTitle)},${_csvField(currentPlanPrice)}',
    )
    ..writeln()
    ..writeln('Attendance Month,Days Present,Total Hours,Average Daily Stay (h)');

  for (final month in _fullAttendanceHistory(kid.id, kid.createdAt, attendance.month)) {
    buffer.writeln(
      '${month.month.year}-${month.month.month.toString().padLeft(2, '0')},'
      '${month.presentDaysCount},${month.totalHours},${month.averageDailyStay.toStringAsFixed(1)}',
    );
  }

  buffer
    ..writeln()
    ..writeln('Plan Change Date,Old Plan,New Plan,Changed By');
  for (final entry in planHistory) {
    buffer.writeln(
      '${entry.date.toIso8601String().split('T').first},${_csvField(entry.oldPlanLabel)},'
      '${_csvField(entry.newPlanLabel)},${_csvField(entry.changedBy)}',
    );
  }

  final bytes = utf8.encode(buffer.toString());
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'child_profile_export'.tr(),
    fileName: 'profile_${kid.fullName.replaceAll(' ', '_')}.csv',
    type: FileType.custom,
    allowedExtensions: ['csv'],
    bytes: bytes,
  );
  if (path == null || !context.mounted) return;

  final file = File(path);
  if (!await file.exists()) {
    await file.writeAsBytes(bytes);
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('child_profile_export_started'.tr())),
  );
}
