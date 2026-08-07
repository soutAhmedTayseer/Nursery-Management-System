import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/schedule_item.dart';
import '../../../../core/theme/app_palette.dart';

const _kNewItemIcon = Icons.event_note_outlined;
const _kNewItemColor = AppColors.schedulePastelSage;

/// Add/edit dialog for one [ScheduleItemModel]. Icon/color aren't editable —
/// not part of the requested CRUD surface; new items get a fixed default.
class ScheduleItemEditDialog extends StatefulWidget {
  const ScheduleItemEditDialog({super.key, this.existing});

  final ScheduleItemModel? existing;

  @override
  State<ScheduleItemEditDialog> createState() => _ScheduleItemEditDialogState();
}

class _ScheduleItemEditDialogState extends State<ScheduleItemEditDialog> {
  late final _titleController = TextEditingController(text: widget.existing?.title ?? '');
  late final _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
  late TimeOfDay _start = _toTimeOfDay(widget.existing?.startMinutes ?? 9 * 60);
  late TimeOfDay _end = _toTimeOfDay(widget.existing?.endMinutes ?? 10 * 60);

  static TimeOfDay _toTimeOfDay(int minutes) => TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _start : _end);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    final result = (widget.existing ?? ScheduleItemModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      title: title,
      icon: _kNewItemIcon,
      themeColor: _kNewItemColor,
    )).copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEdit = widget.existing != null;
    return Dialog(
      backgroundColor: palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'schedule_edit_title'.tr() : 'schedule_add_title'.tr(),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
            ),
            SizedBox(height: 20.h),
            _StyledField(label: 'schedule_field_title'.tr(), controller: _titleController),
            SizedBox(height: 16.h),
            _StyledField(label: 'schedule_field_description'.tr(), controller: _descriptionController, maxLines: 2),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _TimeField(label: 'schedule_field_start'.tr(), time: _start, onTap: () => _pickTime(isStart: true))),
                SizedBox(width: 16.w),
                Expanded(child: _TimeField(label: 'schedule_field_end'.tr(), time: _end, onTap: () => _pickTime(isStart: false))),
              ],
            ),
            SizedBox(height: 28.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('action_cancel'.tr(), style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  child: Text('schedule_save'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({required this.label, required this.controller, this.maxLines = 1});

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: palette.textSecondary)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceSand,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap});

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: palette.textSecondary)),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(color: AppColors.surfaceSand, borderRadius: BorderRadius.circular(16.r)),
            child: Text(time.format(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
          ),
        ),
      ],
    );
  }
}
