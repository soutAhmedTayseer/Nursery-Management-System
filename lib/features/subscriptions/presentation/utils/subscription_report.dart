import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/subscription_plan.dart';

String _csvField(String value) {
  final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Exports a child's plan + billing summary (current plan, price, start
/// date, and change history) as a CSV via the native save dialog.
Future<void> exportSubscriptionReportCsv({
  required BuildContext context,
  required String childName,
  required String parentName,
  required String planTitle,
  required String planPrice,
  required DateTime startDate,
  required List<PlanChangeEntry> history,
}) async {
  final buffer = StringBuffer()
    ..writeln('Child,Parent,Current Plan,Price,Start Date')
    ..writeln('${_csvField(childName)},${_csvField(parentName)},${_csvField(planTitle)},${_csvField(planPrice)},${_formatDate(startDate)}')
    ..writeln()
    ..writeln('Date,Old Plan,New Plan,Changed By');
  for (final entry in history) {
    buffer.writeln(
      '${_formatDate(entry.date)},${_csvField(entry.oldPlanLabel)},${_csvField(entry.newPlanLabel)},${_csvField(entry.changedBy)}',
    );
  }

  final bytes = utf8.encode(buffer.toString());
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'plan_history_export_report'.tr(),
    fileName: 'subscription_${childName.replaceAll(' ', '_')}.csv',
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
    SnackBar(content: Text('plan_history_export_started'.tr())),
  );
}

/// Opens WhatsApp with the same plan + billing summary pre-filled for the
/// parent, keyed off [parentPhone] (digits only, no `+`).
Future<void> sendSubscriptionReportViaWhatsapp({
  required BuildContext context,
  required String parentPhone,
  required String childName,
  required String parentName,
  required String planTitle,
  required String planPrice,
  required DateTime startDate,
  required List<PlanChangeEntry> history,
}) async {
  final digitsOnly = parentPhone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('plan_history_no_phone'.tr())),
    );
    return;
  }

  final historyLines = history.isEmpty
      ? 'plan_history_whatsapp_none'.tr()
      : history.map((e) => '${_formatDate(e.date)}: ${e.oldPlanLabel} -> ${e.newPlanLabel}').join('\n');

  final message = 'plan_history_whatsapp_message'.tr(namedArgs: {
    'child': childName,
    'parent': parentName,
    'plan': planTitle,
    'price': planPrice,
    'startDate': _formatDate(startDate),
    'history': historyLines,
  });

  final uri = Uri.https('wa.me', '/$digitsOnly', {'text': message});
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_invoice_launch_failed'.tr())),
    );
  }
}
