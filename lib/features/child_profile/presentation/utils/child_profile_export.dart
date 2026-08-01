import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../sessions/data/models/kid_session.dart';
import '../cubit/attendance_state.dart';

String _csvField(String value) {
  final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}

/// Exports the child's profile (info, allergies, emergency contact, current
/// plan) plus the currently-viewed month's attendance summary as a CSV.
Future<void> exportChildProfileCsv({
  required BuildContext context,
  required KidSession childData,
  required String currentPlanTitle,
  required String currentPlanPrice,
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
    ..writeln('Attendance Month,Days Present,Total Hours,Average Daily Stay (h)')
    ..writeln(
      '${attendance.month.year}-${attendance.month.month.toString().padLeft(2, '0')},'
      '${attendance.presentDaysCount},${attendance.totalHours},${attendance.averageDailyStay.toStringAsFixed(1)}',
    );

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
