import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';

/// Common allergies as selectable chips instead of a free-text box — faster
/// to fill, consistent data. "Other" reveals a small input; each entry typed
/// there becomes its own removable chip.
class AllergiesSection extends StatefulWidget {
  const AllergiesSection({super.key, this.onChanged});

  /// Called with the localized allergy labels (chip options + custom
  /// entries) whenever the selection changes, so Registration can save them
  /// onto the new Kid record.
  final ValueChanged<List<String>>? onChanged;

  @override
  State<AllergiesSection> createState() => _AllergiesSectionState();
}

class _AllergiesSectionState extends State<AllergiesSection> {
  static const _options = [
    'allergy_peanuts',
    'allergy_dairy',
    'allergy_gluten',
    'allergy_eggs',
    'allergy_seafood',
    'allergy_pollen',
  ];

  final Set<String> _selected = {};
  final List<String> _customAllergies = [];
  final _customController = TextEditingController();
  bool _otherSelected = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomAllergy() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _customAllergies.add(text);
      _customController.clear();
    });
    _notify();
  }

  void _notify() {
    widget.onChanged?.call([for (final option in _selected) option.tr(), ..._customAllergies]);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final chipTextSize = (12 * scale).sp;
    final inputTextSize = (14 * scale).sp;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: AppColors.amberTint,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), bottomLeft: Radius.circular(32.r)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: (18 * scale).r,
                          backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                          child: Icon(Icons.health_and_safety_outlined, color: AppColors.gold, size: (18 * scale).w),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'allergies_section_title'.tr(),
                            style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: [
                        for (final option in _options)
                          FilterChip(
                            label: Text(option.tr(), style: TextStyle(fontSize: chipTextSize, fontWeight: FontWeight.w600)),
                            selected: _selected.contains(option),
                            onSelected: (v) {
                              setState(() => v ? _selected.add(option) : _selected.remove(option));
                              _notify();
                            },
                            selectedColor: AppColors.accentGreen.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.accentGreen,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        for (final custom in _customAllergies)
                          InputChip(
                            label: Text(custom, style: TextStyle(fontSize: chipTextSize, fontWeight: FontWeight.w600)),
                            onDeleted: () {
                              setState(() => _customAllergies.remove(custom));
                              _notify();
                            },
                            deleteIconColor: AppColors.accentGreen,
                            backgroundColor: AppColors.accentGreen.withValues(alpha: 0.1),
                            side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                          ),
                        FilterChip(
                          label: Text('allergy_other'.tr(), style: TextStyle(fontSize: chipTextSize, fontWeight: FontWeight.w600)),
                          selected: _otherSelected,
                          onSelected: (v) => setState(() => _otherSelected = v),
                          selectedColor: AppColors.accentGreen.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.accentGreen,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    if (_otherSelected) ...[
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customController,
                              onSubmitted: (_) => _addCustomAllergy(),
                              textInputAction: TextInputAction.done,
                              style: TextStyle(fontSize: inputTextSize),
                              decoration: InputDecoration(
                                hintText: 'allergy_other_hint'.tr(),
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: inputTextSize),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: (14 * scale).h),
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
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: _addCustomAllergy,
                            icon: const Icon(Icons.add_circle, color: AppColors.accentGreen),
                            iconSize: (28 * scale).w,
                            tooltip: 'allergy_add'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
