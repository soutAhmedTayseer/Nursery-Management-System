import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/subscription_plan.dart';
import '../cubit/plans_cubit.dart';

const _kIconChoices = [
  Icons.calendar_month,
  Icons.calendar_today,
  Icons.access_time,
  Icons.star,
  Icons.holiday_village,
  Icons.event,
  Icons.schedule,
  Icons.local_offer,
];

const _kColorChoices = [
  AppColors.darkGreen,
  AppColors.subscriptionBrown,
  AppColors.amberLabel,
  AppColors.forestGreen,
  AppColors.leafGreen,
  AppColors.gold,
];

int _idCounter = 0;

/// Client-side id for a new category/line item — no backend to assign one
/// yet. Timestamp + a per-run counter avoids collisions between ids minted
/// in the same microsecond.
String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

class _LineItemDraft {
  _LineItemDraft({String? id, String label = '', String price = '', String? badgeText})
      : id = id ?? _newId(),
        labelController = TextEditingController(text: label),
        priceController = TextEditingController(text: price),
        badgeController = TextEditingController(text: badgeText ?? '');

  final String id;
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController badgeController;

  PlanLineItem toLineItem() => PlanLineItem(
        id: id,
        label: labelController.text.trim(),
        price: priceController.text.trim(),
        badgeText: badgeController.text.trim().isEmpty ? null : badgeController.text.trim(),
      );

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    badgeController.dispose();
  }
}

/// Add/edit dialog for a [PlanCategory]. `category == null` is create mode.
class PlanCategoryEditDialog extends StatefulWidget {
  const PlanCategoryEditDialog({super.key, this.category});

  final PlanCategory? category;

  static Future<void> show(BuildContext context, {PlanCategory? category}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PlansCubit>(),
        child: PlanCategoryEditDialog(category: category),
      ),
    );
  }

  @override
  State<PlanCategoryEditDialog> createState() => _PlanCategoryEditDialogState();
}

class _PlanCategoryEditDialogState extends State<PlanCategoryEditDialog> {
  late final TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late bool _isFeatured;
  late List<_LineItemDraft> _items;

  bool get _isEditMode => widget.category != null;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _items.any((i) => i.labelController.text.trim().isNotEmpty && i.priceController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _selectedIcon = category?.icon ?? _kIconChoices.first;
    _selectedColor = category?.themeColor ?? _kColorChoices.first;
    _isFeatured = category?.isFeatured ?? false;
    _items = (category?.lineItems ?? const <PlanLineItem>[])
        .map((i) => _LineItemDraft(id: i.id, label: i.label, price: i.price, badgeText: i.badgeText))
        .toList();
    if (_items.isEmpty) _items.add(_LineItemDraft());
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _save() {
    final validItems = _items
        .map((d) => d.toLineItem())
        .where((i) => i.label.isNotEmpty && i.price.isNotEmpty)
        .toList();
    final category = PlanCategory(
      id: widget.category?.id ?? _newId(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      themeColor: _selectedColor,
      isFeatured: _isFeatured,
      lineItems: validItems,
    );
    final cubit = context.read<PlansCubit>();
    if (_isEditMode) {
      cubit.updateCategory(category);
    } else {
      cubit.addCategory(category);
    }
    Navigator.of(context).pop();
  }

  Future<void> _deleteCategory() async {
    final category = widget.category!;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'subscriptions_delete_category_confirm_title'.tr(),
      message: 'subscriptions_delete_category_confirm_message'.tr(namedArgs: {'name': category.name}),
      confirmLabel: 'subscriptions_delete_category'.tr(),
    );
    if (!confirmed || !mounted) return;
    context.read<PlansCubit>().deleteCategory(category.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      title: Text(_isEditMode
          ? 'subscriptions_category_dialog_title_edit'.tr()
          : 'subscriptions_category_dialog_title_add'.tr()),
      content: SizedBox(
        width: 480.w,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'subscriptions_category_name_label'.tr(),
                  hintText: 'subscriptions_category_name_hint'.tr(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 16.h),
              Text('subscriptions_category_icon_label'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  for (final icon in _kIconChoices)
                    _PickerChip(
                      selected: icon == _selectedIcon,
                      color: _selectedColor,
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Icon(icon, size: AppSpacing.iconSm.w),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Text('subscriptions_category_color_label'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  for (final color in _kColorChoices)
                    _PickerChip(
                      selected: color == _selectedColor,
                      color: color,
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(radius: 10.r, backgroundColor: color),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('subscriptions_category_featured_label'.tr(), style: TextStyle(fontSize: 14.sp)),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              SizedBox(height: 8.h),
              Text('subscriptions_line_items_label'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              SizedBox(height: 8.h),
              for (final item in _items) _LineItemFields(
                key: ValueKey(item.id),
                draft: item,
                onChanged: () => setState(() {}),
                onRemove: _items.length == 1
                    ? null
                    : () => setState(() {
                          item.dispose();
                          _items.remove(item);
                        }),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _items.add(_LineItemDraft())),
                icon: const Icon(Icons.add),
                label: Text('subscriptions_add_line_item'.tr()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditMode)
          TextButton(
            onPressed: _deleteCategory,
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: Text('subscriptions_delete_category'.tr()),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('action_cancel'.tr())),
        ElevatedButton(
          onPressed: _canSave ? _save : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
          child: Text('subscriptions_save'.tr()),
        ),
      ],
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({required this.selected, required this.color, required this.onTap, required this.child});

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? color : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        ),
        child: child,
      ),
    );
  }
}

class _LineItemFields extends StatelessWidget {
  const _LineItemFields({super.key, required this.draft, required this.onChanged, required this.onRemove});

  final _LineItemDraft draft;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: draft.labelController,
              decoration: InputDecoration(hintText: 'subscriptions_line_item_label_hint'.tr()),
              onChanged: (_) => onChanged(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: draft.priceController,
              decoration: InputDecoration(hintText: 'subscriptions_line_item_price_hint'.tr()),
              onChanged: (_) => onChanged(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: draft.badgeController,
              decoration: InputDecoration(hintText: 'subscriptions_line_item_badge_hint'.tr()),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            iconSize: AppSpacing.iconSm.w,
          ),
        ],
      ),
    );
  }
}
