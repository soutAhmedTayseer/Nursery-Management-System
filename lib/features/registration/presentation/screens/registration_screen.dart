import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../widgets/allergies_section.dart';
import '../widgets/emergency_contact_section.dart';
import '../widgets/registration_form_section.dart';
import '../widgets/registration_input_field.dart';
import '../widgets/plan_picker_section.dart';

/// One row of the field grid — one or two fields that must line up together.
class _FieldRow {
  const _FieldRow(this.first, [this.second]);

  final Widget first;
  final Widget? second;
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(sl<SessionsRepository>()),
      child: const _RegistrationPager(),
    );
  }
}

class _RegistrationPager extends StatefulWidget {
  const _RegistrationPager();

  @override
  State<_RegistrationPager> createState() => _RegistrationPagerState();
}

class _RegistrationPagerState extends State<_RegistrationPager> {
  final _pageController = PageController();
  int _currentStep = 0;
  int _formGeneration = 0;

  var _childNameController = TextEditingController();
  var _dobController = TextEditingController();
  var _motherPhoneController = TextEditingController();
  var _fatherPhoneController = TextEditingController();
  String? _selectedPlanId;
  List<String> _allergies = [];
  var _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());

  static const _stepCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _childNameController.dispose();
    _dobController.dispose();
    _motherPhoneController.dispose();
    _fatherPhoneController.dispose();
    super.dispose();
  }

  DateTime? _parseDob() {
    final parts = _dobController.text.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _next(BuildContext context, RegistrationCubit cubit) {
    if (_currentStep < _stepCount - 1) {
      if (!(_formKeys[_currentStep].currentState?.validate() ?? true)) return;
      _goToStep(_currentStep + 1);
      return;
    }
    // Submitting: swipe/step-dot navigation can reach here without ever
    // triggering a step's Next-button validation, so re-validate everything.
    for (var i = 0; i < _stepCount; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? true)) {
        _goToStep(i);
        return;
      }
    }
    if (_motherPhoneController.text.trim().isEmpty && _fatherPhoneController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'registration_parent_required_error'.tr());
      _goToStep(1);
      return;
    }
    final selected = _findSelectedPlan(context);
    if (selected == null) {
      AppSnackbar.showError(context, 'registration_plan_required_error'.tr());
      _goToStep(0);
      return;
    }
    cubit.registerChild(
      fullName: _childNameController.text,
      dateOfBirth: _parseDob(),
      planCategory: selected.$1,
      planItem: selected.$2,
      allergies: _allergies.isEmpty ? null : _allergies.join(', '),
    );
  }

  (PlanCategory, PlanLineItem)? _findSelectedPlan(BuildContext context) {
    final compositeId = _selectedPlanId;
    if (compositeId == null) return null;
    final parts = compositeId.split(':');
    if (parts.length != 2) return null;
    return context.read<PlansCubit>().findLineItem(parts[0], parts[1]);
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  void _resetForNewChild() {
    _pageController.jumpToPage(0);
    _childNameController.dispose();
    _dobController.dispose();
    _motherPhoneController.dispose();
    _fatherPhoneController.dispose();
    setState(() {
      _currentStep = 0;
      _formGeneration++; // forces fresh field widgets, clearing all input state
      _childNameController = TextEditingController();
      _dobController = TextEditingController();
      _motherPhoneController = TextEditingController();
      _fatherPhoneController = TextEditingController();
      _selectedPlanId = null;
      _allergies = [];
      _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());
    });
  }

  /// A step's fields laid out as literal rows, each row an actual [Row] of
  /// up to two fields — so the two cells in a row always share the same
  /// height and stay aligned with each other. On compact, every field just
  /// stacks full-width regardless of pairing.
  Widget _fieldRows(BuildContext context, AppSpacing spacing, List<_FieldRow> rows) {
    final isCompact = context.isCompact;
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) children.add(SizedBox(height: spacing.lg));
      final row = rows[i];
      if (row.second == null) {
        children.add(row.first);
      } else if (isCompact) {
        children.add(row.first);
        children.add(SizedBox(height: spacing.lg));
        children.add(row.second!);
      } else {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: row.first),
              SizedBox(width: spacing.md),
              Expanded(child: row.second!),
            ],
          ),
        );
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final stepLabels = [
      'registration_step_child'.tr(),
      'registration_step_mother'.tr(),
      'registration_step_father'.tr(),
      'registration_step_emergency'.tr(),
    ];

    final pages = [
      RegistrationFormSection(
        title: 'registration_section_child'.tr(),
        icon: Icons.face_retouching_natural,
        accentColor: AppColors.accentGreen,
        children: [
          _fieldRows(context, spacing, [
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_child_name'.tr(),
                hint: 'registration_hint_child_name'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _childNameController,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_dob'.tr(),
                hint: 'registration_hint_date'.tr(),
                inputType: RegistrationFieldInputType.date,
                controller: _dobController,
                required: true,
              ),
              RegistrationInputField(label: 'registration_label_enrol_date'.tr(), hint: 'registration_hint_date'.tr(), inputType: RegistrationFieldInputType.date),
            ),
            _FieldRow(
              RegistrationInputField(label: 'registration_label_nationality'.tr(), hint: 'registration_hint_nationality'.tr(), inputType: RegistrationFieldInputType.letters),
              RegistrationInputField(label: 'registration_label_religion'.tr(), hint: 'registration_hint_religion'.tr(), inputType: RegistrationFieldInputType.letters),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_home_address'.tr(),
                hint: 'registration_hint_home_address'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
              ),
            ),
          ]),
          SizedBox(height: spacing.lg),
          PlanPickerSection(
            selectedCompositeId: _selectedPlanId,
            onChanged: (value) => setState(() => _selectedPlanId = value),
          ),
          SizedBox(height: spacing.lg),
          AllergiesSection(onChanged: (value) => _allergies = value),
        ],
      ),
      RegistrationFormSection(
        title: 'registration_section_mother'.tr(),
        icon: Icons.female_rounded,
        accentColor: AppColors.bronze,
        children: [
          _fieldRows(context, spacing, [
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_mother_phone'.tr(),
                hint: 'registration_hint_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _motherPhoneController,
              ),
              RegistrationInputField(label: 'registration_label_contact_email'.tr(), hint: 'registration_hint_email'.tr(), inputType: RegistrationFieldInputType.email),
            ),
            _FieldRow(
              RegistrationInputField(label: 'registration_label_occupation'.tr(), hint: 'registration_hint_occupation'.tr(), inputType: RegistrationFieldInputType.letters),
              RegistrationInputField(label: 'registration_label_job_title'.tr(), hint: 'registration_hint_job_title'.tr(), inputType: RegistrationFieldInputType.letters),
            ),
            _FieldRow(
              RegistrationInputField(label: 'registration_label_company_name'.tr(), hint: 'registration_hint_company_name'.tr(), inputType: RegistrationFieldInputType.alphanumeric),
              RegistrationInputField(label: 'registration_label_work_phone'.tr(), hint: 'registration_hint_work_phone'.tr(), inputType: RegistrationFieldInputType.digits),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_address_alt'.tr(),
                hint: 'registration_hint_workplace_alt'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                maxLines: 2,
              ),
            ),
          ]),
        ],
      ),
      RegistrationFormSection(
        title: 'registration_section_father'.tr(),
        icon: Icons.male_rounded,
        accentColor: AppColors.textSecondary,
        children: [
          _fieldRows(context, spacing, [
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_father_phone'.tr(),
                hint: 'registration_hint_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _fatherPhoneController,
              ),
              RegistrationInputField(label: 'registration_label_contact_email'.tr(), hint: 'registration_hint_email'.tr(), inputType: RegistrationFieldInputType.email),
            ),
            _FieldRow(
              RegistrationInputField(label: 'registration_label_occupation'.tr(), hint: 'registration_hint_occupation'.tr(), inputType: RegistrationFieldInputType.letters),
              RegistrationInputField(label: 'registration_label_job_title'.tr(), hint: 'registration_hint_job_title'.tr(), inputType: RegistrationFieldInputType.letters),
            ),
            _FieldRow(
              RegistrationInputField(label: 'registration_label_company'.tr(), hint: 'registration_hint_company'.tr(), inputType: RegistrationFieldInputType.alphanumeric),
              RegistrationInputField(label: 'registration_label_work_phone'.tr(), hint: 'registration_hint_work_phone'.tr(), inputType: RegistrationFieldInputType.digits),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_address_alt'.tr(),
                hint: 'registration_hint_workplace'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
              ),
            ),
          ]),
        ],
      ),
      EmergencyContactSection(
        children: [
          RegistrationInputField(
            label: 'registration_label_name_relationship'.tr(),
            hint: 'registration_hint_name_relationship'.tr(),
            inputType: RegistrationFieldInputType.letters,
            maxLines: 2,
          ),
          SizedBox(height: spacing.lg),
          RegistrationInputField(
            label: 'registration_label_contact_number'.tr(),
            hint: 'registration_hint_contact_number'.tr(),
            inputType: RegistrationFieldInputType.digits,
          ),
        ],
      ),
    ];

    return BlocListener<RegistrationCubit, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess) {
          AppSnackbar.showSuccess(context, 'registration_success_message'.tr());
          _resetForNewChild();
        } else if (state is RegistrationError) {
          AppSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLinen,
        // Default keyboard behavior: Scaffold resizes the body so the
        // focused field stays above the keyboard instead of being covered by
        // it, and the per-page SingleChildScrollView auto-scrolls the
        // focused field into view.
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding, vertical: spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Step indicator
                _StepIndicator(
                  labels: stepLabels,
                  currentStep: _currentStep,
                  onStepTapped: _goToStep,
                ),
                SizedBox(height: spacing.xxl),

                // 2. Current step content — fills remaining screen, scrolls internally only if needed
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: const ResponsiveValue<double>(compact: 640, medium: 900, expanded: 980).resolve(context),
                      ),
                      child: PageView(
                        key: ValueKey(_formGeneration),
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentStep = i),
                        children: [
                          for (var i = 0; i < pages.length; i++)
                            Form(key: _formKeys[i], child: SingleChildScrollView(child: pages[i])),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.xl),

                // 3. Footer navigation — on bigger screens, swiping/tapping a
                // step dot replaces Back and Next, so only the final Save
                // action still needs a button down here.
                Builder(builder: (context) {
                  final isLastStep = _currentStep == _stepCount - 1;
                  final showFullFooter = context.isCompact || isLastStep;
                  if (!showFullFooter) return const SizedBox.shrink();
                  final showBackAndStepOf = context.isCompact;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showBackAndStepOf)
                        TextButton(
                          onPressed: _currentStep > 0 ? _back : null,
                          child: Text(
                            'registration_back'.tr(),
                            style: TextStyle(fontSize: (14 * context.uiScale).sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.5),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (showBackAndStepOf)
                        Text(
                          'registration_step_of'.tr(args: ['${_currentStep + 1}', '$_stepCount']),
                          style: TextStyle(fontSize: (13 * context.uiScale).sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                        )
                      else
                        const SizedBox.shrink(),
                      BlocBuilder<RegistrationCubit, RegistrationState>(
                        builder: (context, state) {
                          final isLoading = state is RegistrationLoading;
                          final scale = context.uiScale;
                          return ElevatedButton(
                            onPressed: isLoading ? null : () => _next(context, context.read<RegistrationCubit>()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.leafGreen,
                              padding: EdgeInsets.symmetric(horizontal: spacing.xl, vertical: spacing.md * scale),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    isLastStep ? 'registration_save_button'.tr() : 'registration_next'.tr(),
                                    style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.labels, required this.currentStep, required this.onStepTapped});

  final List<String> labels;
  final int currentStep;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: i <= currentStep ? AppColors.leafGreen : Colors.grey.shade300,
              ),
            ),
          _StepDot(
            index: i,
            label: labels[i],
            isActive: i == currentStep,
            isDone: i < currentStep,
            onTap: () => onStepTapped(i),
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.label, required this.isActive, required this.isDone, required this.onTap});

  final int index;
  final String label;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Column(
        children: [
          CircleAvatar(
            radius: (16 * scale).r,
            backgroundColor: isActive ? AppColors.leafGreen : (isDone ? AppColors.leafGreen.withValues(alpha: 0.15) : Colors.grey.shade200),
            child: isDone
                ? Icon(Icons.check, size: (16 * scale).w, color: AppColors.leafGreen)
                : Text('${index + 1}', style: TextStyle(fontSize: (13 * scale).sp, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey.shade500)),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: (11 * scale).sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.leafGreen : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
