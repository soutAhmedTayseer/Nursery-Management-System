import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/schedule_item.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';
import '../widgets/schedule_item_edit_dialog.dart';

/// Timeline feed matching Figma node 188-415, always sorted by start time.
/// Edit/delete controls are always visible — no drag reorder (order is
/// time-derived, not manual).
class ScheduleFeedScreen extends StatelessWidget {
  const ScheduleFeedScreen({super.key});

  Future<void> _addItem(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    final result = await showDialog<ScheduleItemModel>(context: context, builder: (_) => const ScheduleItemEditDialog());
    if (result != null) cubit.addItem(result);
  }

  Future<void> _editItem(BuildContext context, ScheduleItemModel item) async {
    final cubit = context.read<ScheduleCubit>();
    final result = await showDialog<ScheduleItemModel>(context: context, builder: (_) => ScheduleItemEditDialog(existing: item));
    if (result != null) cubit.updateItem(result);
  }

  Future<void> _deleteItem(BuildContext context, ScheduleItemModel item) async {
    final cubit = context.read<ScheduleCubit>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'schedule_delete_title'.tr(),
      message: 'schedule_delete_message'.tr(namedArgs: {'title': item.title}),
    );
    if (confirmed) cubit.deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final scale = context.uiScale;
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding, vertical: spacing.xxl),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(48.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) => _Header(
                    activeTitle: _activeItem(state.items)?.title,
                    scale: scale,
                    onBack: () => Navigator.of(context).pop(),
                    onAdd: () => _addItem(context),
                  ),
                ),
                SizedBox(height: 40.h),
                BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) {
                    final items = state.items;
                    final nowMinutes = nowInUaeMinutes();
                    return Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          _ScheduleTimelineCard(
                            item: items[i],
                            status: items[i].statusAt(nowMinutes),
                            scale: scale,
                            onEdit: () => _editItem(context, items[i]),
                            onDelete: () => _deleteItem(context, items[i]),
                          ),
                          if (i != items.length - 1) SizedBox(height: 24.h),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ScheduleItemModel? _activeItem(List<ScheduleItemModel> items) {
    final nowMinutes = nowInUaeMinutes();
    for (final item in items) {
      if (item.statusAt(nowMinutes) == ActivityStatus.active) return item;
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeTitle, required this.scale, required this.onBack, required this.onAdd});

  final String? activeTitle;
  final double scale;
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.arrow_back, size: (18 * scale).w, color: AppColors.textSecondary),
                onPressed: onBack,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: activeTitle != null ? AppColors.brandGradientLight.withValues(alpha: 0.3) : AppColors.surfaceSand,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: activeTitle != null ? AppColors.darkGreen : AppColors.textTertiary),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      activeTitle != null
                          ? 'schedule_status_active'.tr(namedArgs: {'title': activeTitle!.toUpperCase()})
                          : 'schedule_status_none'.tr(),
                      style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: activeTitle != null ? AppColors.activeBadgeText : AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text('schedule_screen_title'.tr(), style: TextStyle(fontSize: (30 * scale).sp, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.darkGreen)),
              SizedBox(height: 8.h),
              Text('schedule_screen_subtitle'.tr(), style: TextStyle(fontSize: (15 * scale).sp, color: AppColors.textSecondary)),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.darkGreen, AppColors.brandGradientLight]),
            borderRadius: BorderRadius.all(Radius.circular(9999)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(9999),
              onTap: onAdd,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: (14 * scale).w, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text('schedule_add_button'.tr(), style: TextStyle(fontSize: (14 * scale).sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleTimelineCard extends StatelessWidget {
  const _ScheduleTimelineCard({required this.item, required this.status, required this.scale, required this.onEdit, required this.onDelete});

  final ScheduleItemModel item;
  final ActivityStatus status;
  final double scale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = status == ActivityStatus.active;
    final isUpcoming = status == ActivityStatus.upcoming;

    return Opacity(
      opacity: isUpcoming ? 0.7 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (144 * scale).w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: (48 * scale).w,
                  height: (48 * scale).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.darkGreen : (isUpcoming ? AppColors.neutralChip : item.themeColor),
                    boxShadow: isActive ? [BoxShadow(color: AppColors.darkGreen.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 8))] : null,
                  ),
                  child: Icon(item.icon, size: (20 * scale).w, color: isActive ? Colors.white : AppColors.textPrimary),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatStart(item), style: TextStyle(fontSize: (18 * scale).sp, fontWeight: FontWeight.bold, color: isActive ? AppColors.darkGreen : AppColors.textPrimary)),
                        Text('schedule_to_time'.tr(namedArgs: {'time': _formatEnd(item)}), style: TextStyle(fontSize: (14 * scale).sp, color: isActive ? AppColors.darkGreen.withValues(alpha: 0.8) : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isActive ? 24.w : 20.w),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : (isUpcoming ? AppColors.surfaceCream.withValues(alpha: 0.5) : AppColors.surfaceCream),
                borderRadius: BorderRadius.circular(32.r),
                border: isActive
                    ? Border.all(color: AppColors.darkGreen.withValues(alpha: 0.2), width: 2)
                    : (isUpcoming ? Border.all(color: Colors.grey.withValues(alpha: 0.15)) : null),
                boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 12))] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(fontSize: ((isActive ? 24 : 20) * scale).sp, fontWeight: isActive ? FontWeight.w800 : FontWeight.bold, letterSpacing: isActive ? -0.6 : 0, color: AppColors.textPrimary),
                        ),
                      ),
                      if (isActive) ...[
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(color: AppColors.darkGreen, borderRadius: BorderRadius.circular(9999)),
                          child: Text('schedule_in_session_badge'.tr(), style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: Colors.white)),
                        ),
                      ],
                      SizedBox(width: 8.w),
                      _RowIconButton(icon: Icons.edit_outlined, color: AppColors.textSecondary, onTap: onEdit),
                      SizedBox(width: 4.w),
                      _RowIconButton(icon: Icons.delete_outline, color: AppColors.dangerRed, onTap: onDelete),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    SizedBox(height: isActive ? 12.h : 3.h),
                    Text(item.description, style: TextStyle(fontSize: ((isActive ? 16 : 14) * scale).sp, color: AppColors.textSecondary, height: 1.4)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStart(ScheduleItemModel item) => item.timeSlotLabel.split(' - ').first;
  String _formatEnd(ScheduleItemModel item) => item.timeSlotLabel.split(' - ').last;
}

class _RowIconButton extends StatelessWidget {
  const _RowIconButton({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSand,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 16.w, color: color),
        ),
      ),
    );
  }
}
