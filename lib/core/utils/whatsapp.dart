import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a WhatsApp chat with [phone], optionally pre-filling [message].
///
/// Shared by the invoice send button and the dashboard's "Message Parent"
/// alert action so both handle a missing number and a failed launch the
/// same way instead of each inventing their own.
Future<void> openWhatsappChat(
  BuildContext context, {
  required String phone,
  String? message,
}) async {
  final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_invoice_no_phone'.tr())),
    );
    return;
  }

  final uri = Uri.https('wa.me', '/$digitsOnly', {
    if (message != null && message.isNotEmpty) 'text': message,
  });
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_invoice_launch_failed'.tr())),
    );
  }
}
