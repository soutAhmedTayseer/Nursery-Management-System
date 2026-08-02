import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';

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

class RegistrationInputField extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLines;
  final RegistrationFieldInputType inputType;

  /// Lets a caller read this field's value (e.g. child name/DOB, which the
  /// registration flow needs to build the new Kid record). Fields that don't
  /// pass one keep managing their own internal controller, unread.
  final TextEditingController? controller;

  const RegistrationInputField({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.inputType = RegistrationFieldInputType.text,
    this.controller,
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

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: (10 * scale).sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiary,
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
          style: TextStyle(fontSize: (14 * scale).sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: (14 * scale).sp),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _suffixIcon == null ? null : Icon(_suffixIcon, size: (18 * scale).w, color: Colors.grey.shade500),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: (16 * scale).h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
