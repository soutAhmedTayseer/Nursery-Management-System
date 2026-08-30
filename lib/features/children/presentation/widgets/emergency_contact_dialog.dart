import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/children_repository.dart';

/// Collects a new emergency contact. Pops [NewEmergencyContact] on submit,
/// null on cancel. Shared by the profile card and the edit pager.
class EmergencyContactDialog extends StatefulWidget {
  const EmergencyContactDialog({super.key});

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'registration_error_required'.tr() : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('child_details_contact_add'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              validator: _required,
              decoration: InputDecoration(
                  labelText: 'registration_label_emergency_name'.tr()),
            ),
            TextFormField(
              controller: _relationship,
              validator: _required,
              decoration: InputDecoration(
                  labelText: 'registration_label_emergency_relationship'.tr()),
            ),
            TextFormField(
              controller: _phone,
              validator: _required,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: 'registration_label_contact_number'.tr()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('action_cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              NewEmergencyContact(
                name: _name.text.trim(),
                relationship: _relationship.text.trim(),
                phone: _phone.text.trim(),
              ),
            );
          },
          child: Text('child_details_contact_add'.tr()),
        ),
      ],
    );
  }
}
