import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Constrains what a field will accept, and what UI it uses to accept it.
enum RegistrationFieldInputType {
  text,
  letters,
  digits,
  alphanumeric,
  email,
  date,
  time,
}

// Arabic block ؀-ۿ so labels/hints translated to ar still work as
// letters, not just Latin.
final _lettersOnly = RegExp(r'[a-zA-Z؀-ۿ ]');
final _alphanumeric = RegExp(r'[a-zA-Z0-9؀-ۿ ,\.\-]');
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phonePattern = RegExp(r'^\d{7,15}$');

class RegistrationInputField extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLines;
  final RegistrationFieldInputType inputType;

  /// Lets a caller read this field's value (e.g. child name/DOB, which the
  /// registration flow needs to build the new Kid record). Fields that don't
  /// pass one keep managing their own internal controller, unread.
  final TextEditingController? controller;

  /// Blocks form submission when left empty. Fields left false are still
  /// format-validated (email/phone shape) if the visitor typed something,
  /// but an empty value is accepted — used for the mother/father sections,
  /// where only one parent's details need to be filled in, not both.
  final bool required;

  const RegistrationInputField({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.inputType = RegistrationFieldInputType.text,
    this.controller,
    this.required = false,
  });

  @override
  State<RegistrationInputField> createState() => _RegistrationInputFieldState();
}

class _RegistrationInputFieldState extends State<RegistrationInputField> {
  TextEditingController? _ownController;
  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());

  bool get _isDate => widget.inputType == RegistrationFieldInputType.date;
  bool get _isTime => widget.inputType == RegistrationFieldInputType.time;
  bool get _isPicker => _isDate || _isTime;

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      setState(() => _controller.text = '$d/$m/${picked.year}');
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && context.mounted) {
      setState(() => _controller.text = picked.format(context));
    }
  }

  TextInputType get _keyboardType => switch (widget.inputType) {
        RegistrationFieldInputType.digits => TextInputType.number,
        RegistrationFieldInputType.email => TextInputType.emailAddress,
        RegistrationFieldInputType.date || RegistrationFieldInputType.time => TextInputType.none,
        _ => TextInputType.text,
      };

  List<TextInputFormatter> get _formatters => switch (widget.inputType) {
        RegistrationFieldInputType.digits => [FilteringTextInputFormatter.digitsOnly],
        RegistrationFieldInputType.letters => [FilteringTextInputFormatter.allow(_lettersOnly)],
        RegistrationFieldInputType.alphanumeric => [FilteringTextInputFormatter.allow(_alphanumeric)],
        _ => const [],
      };

  IconData? get _suffixIcon => switch (widget.inputType) {
        RegistrationFieldInputType.date => Icons.calendar_today_rounded,
        RegistrationFieldInputType.time => Icons.access_time_rounded,
        _ => null,
      };

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return widget.required ? 'registration_error_required'.tr() : null;
    }
    return switch (widget.inputType) {
      RegistrationFieldInputType.email => _emailPattern.hasMatch(text) ? null : 'registration_error_email'.tr(),
      RegistrationFieldInputType.digits => _phonePattern.hasMatch(text) ? null : 'registration_error_phone'.tr(),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: (10 * scale).sp,
            fontWeight: FontWeight.w800,
            color: palette.textTertiary,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _controller,
          maxLines: widget.maxLines,
          readOnly: _isPicker,
          keyboardType: _keyboardType,
          inputFormatters: _formatters,
          onTap: _isDate ? _pickDate : (_isTime ? _pickTime : null),
          validator: _validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(fontSize: (14 * scale).sp, color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: palette.textTertiary, fontSize: (14 * scale).sp),
            filled: true,
            fillColor: palette.card,
            suffixIcon: _suffixIcon == null ? null : Icon(_suffixIcon, size: (18 * scale).w, color: palette.textTertiary),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: (16 * scale).h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: palette.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
