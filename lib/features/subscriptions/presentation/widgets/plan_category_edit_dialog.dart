import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/subscription_plan.dart';
import '../cubit/plans_cubit.dart';
import '../../../../core/theme/app_palette.dart';

/// Fixed defaults for a newly created category — icon/color are no longer
/// admin-editable (see design change: this dialog dropped the icon/color
/// pickers), an existing category being edited keeps its current icon/color
/// unchanged instead.
const _kDefaultIcon = Icons.calendar_month;
const _kDefaultColor = AppColors.darkGreen;

int _idCounter = 0;

/// Client-side id for a new category/line item — no backend to assign one
/// yet. Timestamp + a per-run counter avoids collisions between ids minted
/// in the same microsecond.
String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

/// Strips a trailing "AED" the price field's own prefix already implies —
/// used both to populate the field from stored data (`"600 AED"` → `"600"`)
/// and to clean up anything the admin typed manually despite the prefix.
String _stripAed(String price) => price.replaceAll(RegExp(r'\s*AED\s*$', caseSensitive: false), '').trim();

class _LineItemDraft {
  _LineItemDraft({String? id, String label = '', String price = '', String? badgeText})
      : id = id ?? _newId(),
        labelController = TextEditingController(text: label),
        priceController = TextEditingController(text: _stripAed(price)),
        badgeController = TextEditingController(text: badgeText ?? '');

  final String id;
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController badgeController;

  PlanLineItem toLineItem() {
    final rawPrice = _stripAed(priceController.text);
    return PlanLineItem(
      id: id,
      label: labelController.text.trim(),
      price: rawPrice.isEmpty ? '' : '$rawPrice AED',
      badgeText: badgeController.text.trim().isEmpty ? null : badgeController.text.trim(),
    );
  }

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    badgeController.dispose();
  }
}

/// Add/edit dialog for a [PlanCategory]. `category == null` is create mode.
/// Styled after the "Create Custom Plan" modal design — a rounded card
/// with boxed, label-above-input fields instead of a default Material
/// [AlertDialog] layout. Icon/color are fixed (no picker) — see
/// [_kDefaultIcon]/[_kDefaultColor].
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
      icon: widget.category?.icon ?? _kDefaultIcon,
      themeColor: widget.category?.themeColor ?? _kDefaultColor,
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
    final palette = context.palette;
    return Dialog(
      backgroundColor: palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _isEditMode
                          ? 'subscriptions_category_dialog_title_edit'.tr()
                          : 'subscriptions_category_dialog_title_add'.tr(),
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: palette.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    child: Icon(Icons.close, size: AppSpacing.iconMd.w, color: palette.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'subscriptions_category_dialog_subtitle'.tr(),
                style: TextStyle(fontSize: 14.sp, color: palette.textSecondary),
              ),
              SizedBox(height: 24.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StyledField(
                        label: 'subscriptions_category_name_label'.tr(),
                        controller: _nameController,
                        hint: 'subscriptions_category_name_hint'.tr(),
                        onChanged: () => setState(() {}),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSand,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('subscriptions_category_featured_label'.tr(), style: TextStyle(fontSize: 14.sp)),
                          value: _isFeatured,
                          onChanged: (v) => setState(() => _isFeatured = v),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'subscriptions_line_items_label'.tr().toUpperCase(),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: palette.textSecondary, letterSpacing: 0.6),
                      ),
                      SizedBox(height: 8.h),
                      for (final item in _items)
                        _LineItemFields(
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
              SizedBox(height: 16.h),
              const Divider(height: 1),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isEditMode)
                    TextButton(
                      onPressed: _deleteCategory,
                      style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
                      child: Text('subscriptions_delete_category'.tr()),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('action_cancel'.tr())),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: _canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        ),
                        child: Text('subscriptions_save'.tr(), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A boxed input with an uppercase caption above it, matching the
/// "Create Custom Plan" reference design's field style.
class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.prefixText,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: palette.textSecondary, letterSpacing: 0.6),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSand,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
          ),
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ],
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
    final palette = context.palette;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.cardMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StyledField(
                  label: 'subscriptions_line_item_label_hint'.tr(),
                  controller: draft.labelController,
                  hint: 'subscriptions_line_item_label_hint'.tr(),
                  onChanged: onChanged,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StyledField(
                  label: 'subscriptions_line_item_price_hint'.tr(),
                  controller: draft.priceController,
                  hint: 'subscriptions_line_item_price_hint'.tr(),
                  prefixText: 'AED ',
                  onChanged: onChanged,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                iconSize: AppSpacing.iconSm.w,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _StyledField(
            label: 'subscriptions_line_item_badge_hint'.tr(),
            controller: draft.badgeController,
            hint: 'subscriptions_line_item_badge_hint'.tr(),
            onChanged: () {},
          ),
        ],
      ),
    );
  }
}
