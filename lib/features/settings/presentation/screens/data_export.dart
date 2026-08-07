import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/testing/attendance_store.dart';
import '../../../finance/domain/payment_records.dart';
import '../../../finance/presentation/cubit/audit_log_cubit.dart';
import '../../../finance/presentation/cubit/finance_cubit.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';

String _csvField(String value) {
  final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
  return needsQuoting ? '"${value.replaceAll('"', '""')}"' : value;
}

/// Exports the whole dataset as one CSV: enrolled children and their plans,
/// the current payment ledger, the attendance log, and the activity trail.
///
/// Sectioned rather than split across files so a single export is enough to
/// hand over or archive before the backend exists.
Future<void> exportAllDataCsv(BuildContext context) async {
  final assignments = context.read<PlanAssignmentsCubit>().state;
  final plans = context.read<PlansCubit>().state;
  final finance = context.read<FinanceCubit>().state;
  final auditEntries = context.read<AuditLogCubit>().state;

  final buffer = StringBuffer()
    ..writeln('# Children & Plans')
    ..writeln('Child,Parent,Parent Phone,Category,Plan,Assigned On');
  for (final assignment in assignments.byKidId.values) {
    final item = context.read<PlansCubit>().findLineItem(assignment.categoryId, assignment.lineItemId);
    buffer.writeln(
      '${_csvField(assignment.kidName)},${_csvField(assignment.parentName)},'
      '${_csvField(assignment.parentPhone)},${_csvField(item?.$1.name ?? '')},'
      '${_csvField(item?.$2.label ?? '')},${assignment.assignedAt.toIso8601String().split('T').first}',
    );
  }

  buffer
    ..writeln()
    ..writeln('# Payment Ledger')
    ..writeln('Child,Parent,Base Fee,Overtime Hours,Overtime Amount,Penalty,Total Due,Status');
  for (final record in derivePaymentRecords(assignments, plans, finance)) {
    buffer.writeln(
      '${_csvField(record.childName)},${_csvField(record.parentName)},${record.baseFee},'
      '${record.overtimeHours.toStringAsFixed(2)},${record.overtimeAmount.toStringAsFixed(2)},'
      '${record.penaltyAmount},${record.totalDue.toStringAsFixed(2)},${record.isPaid ? 'Paid' : 'Unpaid'}',
    );
  }

  buffer
    ..writeln()
    ..writeln('# Attendance Log')
    ..writeln('Child,Date,Checked In,Checked Out,Hours');
  final store = AttendanceStore.instance;
  for (final assignment in assignments.byKidId.values) {
    for (final record in store.forKid(assignment.kidId)) {
      buffer.writeln(
        '${_csvField(assignment.kidName)},${record.day.toIso8601String().split('T').first},'
        '${record.checkIn.toIso8601String()},${record.checkOut?.toIso8601String() ?? ''},'
        '${record.hours.toStringAsFixed(2)}',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('# Activity Log')
    ..writeln('When,Actor,Action,Child,Amount');
  for (final entry in auditEntries) {
    buffer.writeln(
      '${entry.at.toIso8601String()},${_csvField(entry.actor)},${entry.action.name},'
      '${_csvField(entry.subjectName)},${entry.amount?.toStringAsFixed(2) ?? ''}',
    );
  }

  final bytes = utf8.encode(buffer.toString());
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'settings_export_action'.tr(),
    fileName: 'nursery_export_${DateTime.now().toIso8601String().split('T').first}.csv',
    type: FileType.custom,
    allowedExtensions: ['csv'],
    bytes: bytes,
  );
  if (path == null || !context.mounted) return;

  // file_picker writes `bytes` for us on mobile/Linux; on Windows/macOS it
  // only returns the chosen path, so write it ourselves if still missing.
  final file = File(path);
  if (!await file.exists()) await file.writeAsBytes(bytes);

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('settings_export_done'.tr())),
  );
}
