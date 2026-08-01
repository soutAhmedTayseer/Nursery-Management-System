import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/finance_model.dart';

/// Opens WhatsApp with the invoice summary pre-filled for [record]'s parent.
Future<void> sendInvoiceViaWhatsapp(BuildContext context, PaymentRecord record) async {
  final digitsOnly = record.parentPhone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_invoice_no_phone'.tr())),
    );
    return;
  }

  final message = 'finance_invoice_message'.tr(namedArgs: {
    'parent': record.parentName,
    'child': record.childName,
    'baseFee': record.baseFee.toInt().toString(),
    'overtimeHours': record.overtimeHours.toString(),
    'penalty': record.penaltyAmount.toInt().toString(),
    'total': record.totalDue.toInt().toString(),
  });

  final uri = Uri.https('wa.me', '/$digitsOnly', {'text': message});
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_invoice_launch_failed'.tr())),
    );
  }
}
