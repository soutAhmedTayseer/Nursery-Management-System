import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/whatsapp.dart';
import '../../data/models/finance_model.dart';

/// Opens WhatsApp with the invoice summary pre-filled for [record]'s parent.
Future<void> sendInvoiceViaWhatsapp(BuildContext context, PaymentRecord record) {
  final message = 'finance_invoice_message'.tr(namedArgs: {
    'parent': record.parentName,
    'child': record.childName,
    'baseFee': record.baseFee.toInt().toString(),
    'overtimeHours': record.overtimeHours.toStringAsFixed(1),
    'overtimeAmount': record.overtimeAmount.toInt().toString(),
    'penalty': record.penaltyAmount.toInt().toString(),
    'total': record.totalDue.toInt().toString(),
  });
  return openWhatsappChat(context, phone: record.parentPhone, message: message);
}
