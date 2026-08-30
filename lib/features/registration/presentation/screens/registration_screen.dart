import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../children/data/repositories/children_repository.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../widgets/agreement_section.dart';
import '../widgets/allergies_section.dart';
import '../widgets/emergency_contact_section.dart';
import '../widgets/registration_form_section.dart';
import '../widgets/registration_input_field.dart';
import '../widgets/plan_picker_section.dart';
import '../../../../core/theme/app_palette.dart';

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
      create: (context) => RegistrationCubit(sl<ChildrenRepository>()),
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

  // Every field gets a controller held here in State, so its value survives
  // PageView disposing the off-screen step (that was the "data lost on
  // back/next" bug — uncontrolled TextFormFields were rebuilt empty).
  late _RegistrationControllers _c = _RegistrationControllers();

  String? _selectedPlanId;
  List<String> _allergies = [];
  bool _agreementChecked = false;
  bool? _mediaConsent;
  var _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());

  static const _stepCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _c.dispose();
    super.dispose();
  }

  String _todayLabel() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return '$d/$m/${now.year}';
  }

  DateTime? _parseDmy(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _jumpTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Navigation entry point for the Next button AND the step dots. Going
  /// backward is always free; going forward runs the validator for every
  /// step being skipped over and stops on the first incomplete one.
  void _goToStep(int target) {
    if (target <= _currentStep) {
      _jumpTo(target);
      return;
    }
    for (var i = _currentStep; i < target; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? true)) {
        _jumpTo(i);
        return;
      }
      if (i == 2 && _fatherAnyFilled && !_fatherAllFilled) {
        AppSnackbar.showError(
          context,
          'registration_father_all_or_none_error'.tr(),
        );
        _jumpTo(2);
        return;
      }
    }
    _jumpTo(target);
  }

  /// Father is optional as a block: fill all of it or none of it.
  List<String> get _fatherValues => [
        _c.fatherName.text,
        _c.fatherPhone.text,
        _c.fatherEmail.text,
        _c.fatherOccupation.text,
        _c.fatherJobTitle.text,
        _c.fatherCompany.text,
        _c.fatherWorkPhone.text,
        _c.fatherAddress.text,
      ].map((v) => v.trim()).toList();

  bool get _fatherAnyFilled => _fatherValues.any((v) => v.isNotEmpty);
  bool get _fatherAllFilled => _fatherValues.every((v) => v.isNotEmpty);

  void _next(BuildContext context, RegistrationCubit cubit) {
    if (_currentStep < _stepCount - 1) {
      // _goToStep runs the current step's validator (and the father rule)
      // before it will move forward.
      _goToStep(_currentStep + 1);
      return;
    }
    // Submitting: swipe/step-dot navigation can reach here without ever
    // triggering a step's Next-button validation, so re-validate everything.
    for (var i = 0; i < _stepCount; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? true)) {
        _jumpTo(i);
        return;
      }
    }
    if (_fatherAnyFilled && !_fatherAllFilled) {
      AppSnackbar.showError(context, 'registration_father_all_or_none_error'.tr());
      _goToStep(2);
      return;
    }
    if (_selectedPlanId == null) {
      AppSnackbar.showError(context, 'registration_plan_required_error'.tr());
      _goToStep(0);
      return;
    }
    if (_mediaConsent == null) {
      AppSnackbar.showError(
        context,
        'registration_agreement_media_required_error'.tr(),
      );
      _goToStep(_stepCount - 1);
      return;
    }
    if (!_agreementChecked) {
      AppSnackbar.showError(
        context,
        'registration_agreement_checkbox_required_error'.tr(),
      );
      _goToStep(_stepCount - 1);
      return;
    }

    final dob = _parseDmy(_c.dob.text);
    final enrol = _parseDmy(_c.enrolDate.text) ?? DateTime.now();
    if (dob == null) {
      AppSnackbar.showError(context, 'registration_error_required'.tr());
      _goToStep(0);
      return;
    }

    cubit.submit(
      ChildInput(
        fullName: _c.childName.text.trim(),
        dateOfBirth: dob,
        enrollmentDate: enrol,
        nationality: _c.nationality.text.trim(),
        religion: _c.religion.text.trim(),
        homeAddress: _c.homeAddress.text.trim(),
        allergies: _allergies.isEmpty ? null : _allergies.join(', '),
        mother: ParentContact(
          fullName: _c.motherName.text.trim(),
          phone: _c.motherPhone.text.trim(),
          email: _c.motherEmail.text.trim(),
          occupation: _c.motherOccupation.text.trim(),
          jobTitle: _c.motherJobTitle.text.trim(),
          companyName: _c.motherCompany.text.trim(),
          workPhone: _c.motherWorkPhone.text.trim(),
          address: _c.motherAddress.text.trim(),
        ),
        father: ParentContact(
          fullName: _c.fatherName.text.trim(),
          phone: _c.fatherPhone.text.trim(),
          email: _c.fatherEmail.text.trim(),
          occupation: _c.fatherOccupation.text.trim(),
          jobTitle: _c.fatherJobTitle.text.trim(),
          companyName: _c.fatherCompany.text.trim(),
          workPhone: _c.fatherWorkPhone.text.trim(),
          address: _c.fatherAddress.text.trim(),
        ),
        agreement: ChildAgreement(
          mediaPermission: _mediaConsent ?? false,
          parentSignature: _c.signature.text.trim(),
          signedDate: DateTime.now(),
          acceptedTerms: _agreementChecked,
        ),
        emergencyContacts: [
          NewEmergencyContact(
            name: _c.emergencyName.text.trim(),
            relationship: _c.emergencyRelationship.text.trim(),
            phone: _c.emergencyPhone.text.trim(),
          ),
        ],
      ),
    );
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  void _resetForNewChild() {
    _pageController.jumpToPage(0);
    _c.dispose();
    setState(() {
      _currentStep = 0;
      _formGeneration++; // forces fresh field widgets, clearing all input state
      _c = _RegistrationControllers();
      _selectedPlanId = null;
      _allergies = [];
      _agreementChecked = false;
      _mediaConsent = null;
      _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());
    });
  }

  /// A step's fields laid out as literal rows, each row an actual [Row] of
  /// up to two fields — so the two cells in a row always share the same
  /// height and stay aligned with each other. On compact, every field just
  /// stacks full-width regardless of pairing.
  Widget _fieldRows(
    BuildContext context,
    AppSpacing spacing,
    List<_FieldRow> rows,
  ) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spacing = AppSpacing.of(context);
    final stepLabels = [
      'registration_step_child'.tr(),
      'registration_step_mother'.tr(),
      'registration_step_father'.tr(),
      'registration_step_emergency'.tr(),
      'registration_step_agreement'.tr(),
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
                controller: _c.childName,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_dob'.tr(),
                hint: 'registration_hint_date'.tr(),
                inputType: RegistrationFieldInputType.date,
                controller: _c.dob,
                required: true,
              ),
              RegistrationInputField(
                label: 'registration_label_enrol_date'.tr(),
                hint: 'registration_hint_date'.tr(),
                inputType: RegistrationFieldInputType.date,
                controller: _c.enrolDate,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_nationality'.tr(),
                hint: 'registration_hint_nationality'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.nationality,
                required: true,
              ),
              RegistrationInputField(
                label: 'registration_label_religion'.tr(),
                hint: 'registration_hint_religion'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.religion,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_home_address'.tr(),
                hint: 'registration_hint_home_address'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                controller: _c.homeAddress,
                required: true,
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
                label: 'registration_label_mother_name'.tr(),
                hint: 'registration_hint_parent_name'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.motherName,
                required: true,
              ),
              RegistrationInputField(
                label: 'registration_label_mother_phone'.tr(),
                hint: 'registration_hint_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _c.motherPhone,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_contact_email'.tr(),
                hint: 'registration_hint_email'.tr(),
                inputType: RegistrationFieldInputType.email,
                controller: _c.motherEmail,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_occupation'.tr(),
                hint: 'registration_hint_occupation'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.motherOccupation,
                required: true,
              ),
              RegistrationInputField(
                label: 'registration_label_job_title'.tr(),
                hint: 'registration_hint_job_title'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.motherJobTitle,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_company_name'.tr(),
                hint: 'registration_hint_company_name'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                controller: _c.motherCompany,
                required: true,
              ),
              RegistrationInputField(
                label: 'registration_label_work_phone'.tr(),
                hint: 'registration_hint_work_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _c.motherWorkPhone,
                required: true,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_address_alt'.tr(),
                hint: 'registration_hint_workplace_alt'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                maxLines: 2,
                controller: _c.motherAddress,
                required: true,
              ),
            ),
          ]),
        ],
      ),
      RegistrationFormSection(
        title: 'registration_section_father'.tr(),
        icon: Icons.male_rounded,
        accentColor: palette.textSecondary,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.md),
            child: Text(
              'registration_father_optional_hint'.tr(),
              style: TextStyle(
                fontSize: (12 * context.uiScale).sp,
                color: palette.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _fieldRows(context, spacing, [
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_father_name'.tr(),
                hint: 'registration_hint_parent_name'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.fatherName,
              ),
              RegistrationInputField(
                label: 'registration_label_father_phone'.tr(),
                hint: 'registration_hint_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _c.fatherPhone,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_contact_email'.tr(),
                hint: 'registration_hint_email'.tr(),
                inputType: RegistrationFieldInputType.email,
                controller: _c.fatherEmail,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_occupation'.tr(),
                hint: 'registration_hint_occupation'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.fatherOccupation,
              ),
              RegistrationInputField(
                label: 'registration_label_job_title'.tr(),
                hint: 'registration_hint_job_title'.tr(),
                inputType: RegistrationFieldInputType.letters,
                controller: _c.fatherJobTitle,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_company'.tr(),
                hint: 'registration_hint_company'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                controller: _c.fatherCompany,
              ),
              RegistrationInputField(
                label: 'registration_label_work_phone'.tr(),
                hint: 'registration_hint_work_phone'.tr(),
                inputType: RegistrationFieldInputType.digits,
                controller: _c.fatherWorkPhone,
              ),
            ),
            _FieldRow(
              RegistrationInputField(
                label: 'registration_label_address_alt'.tr(),
                hint: 'registration_hint_workplace'.tr(),
                inputType: RegistrationFieldInputType.alphanumeric,
                controller: _c.fatherAddress,
              ),
            ),
          ]),
        ],
      ),
      EmergencyContactSection(
        children: [
          RegistrationInputField(
            label: 'registration_label_emergency_name'.tr(),
            hint: 'registration_hint_emergency_name'.tr(),
            inputType: RegistrationFieldInputType.letters,
            controller: _c.emergencyName,
            required: true,
          ),
          SizedBox(height: spacing.lg),
          RegistrationInputField(
            label: 'registration_label_emergency_relationship'.tr(),
            hint: 'registration_hint_emergency_relationship'.tr(),
            inputType: RegistrationFieldInputType.letters,
            controller: _c.emergencyRelationship,
            required: true,
          ),
          SizedBox(height: spacing.lg),
          RegistrationInputField(
            label: 'registration_label_contact_number'.tr(),
            hint: 'registration_hint_contact_number'.tr(),
            inputType: RegistrationFieldInputType.digits,
            controller: _c.emergencyPhone,
            required: true,
          ),
        ],
      ),
      AgreementSection(
        children: [
          Text(
            'registration_agreement_allergy_recap_label'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: (10 * context.uiScale).sp,
              fontWeight: FontWeight.w800,
              color: palette.textTertiary,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _allergies.isEmpty
                ? 'registration_agreement_allergy_recap_none'.tr()
                : _allergies.join(', '),
            style: TextStyle(
              fontSize: (14 * context.uiScale).sp,
              color: palette.textPrimary,
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'registration_agreement_media_release_label'.tr(),
            style: TextStyle(
              fontSize: (13 * context.uiScale).sp,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          RadioListTile<bool>(
            contentPadding: EdgeInsets.zero,
            title: Text('registration_agreement_media_yes'.tr()),
            value: true,
            groupValue: _mediaConsent,
            onChanged: (v) => setState(() => _mediaConsent = v),
          ),
          RadioListTile<bool>(
            contentPadding: EdgeInsets.zero,
            title: Text('registration_agreement_media_no'.tr()),
            value: false,
            groupValue: _mediaConsent,
            onChanged: (v) => setState(() => _mediaConsent = v),
          ),
          SizedBox(height: spacing.lg),
          RegistrationInputField(
            label: 'registration_agreement_signature_label'.tr(),
            hint: 'registration_agreement_signature_hint'.tr(),
            inputType: RegistrationFieldInputType.letters,
            controller: _c.signature,
            required: true,
          ),
          SizedBox(height: spacing.lg),
          Text(
            'registration_agreement_date_label'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: (10 * context.uiScale).sp,
              fontWeight: FontWeight.w800,
              color: palette.textTertiary,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _todayLabel(),
            style: TextStyle(
              fontSize: (14 * context.uiScale).sp,
              color: palette.textPrimary,
            ),
          ),
          SizedBox(height: spacing.lg),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _agreementChecked,
            onChanged: (v) => setState(() => _agreementChecked = v ?? false),
            title: Text(
              'registration_agreement_checkbox_label'.tr(),
              style: TextStyle(
                fontSize: (13 * context.uiScale).sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ];

    return BlocListener<RegistrationCubit, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess) {
          final name = state.child?.fullName;
          AppSnackbar.showSuccess(
            context,
            name == null
                ? 'registration_success_message'.tr()
                : 'registration_success_named'.tr(namedArgs: {'name': name}),
          );
          _resetForNewChild();
        } else if (state is RegistrationError) {
          // The message is either a translation key or an API detail string;
          // `.tr()` returns the key unchanged when it isn't a known key.
          AppSnackbar.showError(context, state.message.tr());
        }
      },
      child: Scaffold(
        backgroundColor: palette.page,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.pagePadding,
              vertical: spacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(
                  labels: stepLabels,
                  currentStep: _currentStep,
                  onStepTapped: _goToStep,
                ),
                SizedBox(height: spacing.xxl),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: const ResponsiveValue<double>(
                          compact: 640,
                          medium: 900,
                          expanded: 980,
                        ).resolve(context),
                      ),
                      child: PageView(
                        key: ValueKey(_formGeneration),
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentStep = i),
                        children: [
                          for (var i = 0; i < pages.length; i++)
                            _KeepAlivePage(
                              child: Form(
                                key: _formKeys[i],
                                child: SingleChildScrollView(child: pages[i]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.xl),
                Builder(
                  builder: (context) {
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
                              style: TextStyle(
                                fontSize: (14 * context.uiScale).sp,
                                fontWeight: FontWeight.bold,
                                color: palette.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (showBackAndStepOf)
                          Text(
                            'registration_step_of'.tr(
                              args: ['${_currentStep + 1}', '$_stepCount'],
                            ),
                            style: TextStyle(
                              fontSize: (13 * context.uiScale).sp,
                              color: palette.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        BlocBuilder<RegistrationCubit, RegistrationState>(
                          builder: (context, state) {
                            final isLoading = state is RegistrationLoading;
                            final scale = context.uiScale;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _next(
                                      context,
                                      context.read<RegistrationCubit>(),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.leafGreen,
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing.xl,
                                  vertical: spacing.md * scale,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isLastStep
                                          ? 'registration_save_button'.tr()
                                          : 'registration_next'.tr(),
                                      style: TextStyle(
                                        fontSize: (16 * scale).sp,
                                        fontWeight: FontWeight.bold,
                                        color: palette.card,
                                      ),
                                    ),
                            );
                          },
                        ),
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
}

/// Owns one [TextEditingController] per form field. Lives on the pager's
/// State so values persist while the user steps back and forth.
class _RegistrationControllers {
  final childName = TextEditingController();
  final dob = TextEditingController();
  final enrolDate = TextEditingController();
  final nationality = TextEditingController();
  final religion = TextEditingController();
  final homeAddress = TextEditingController();

  final motherName = TextEditingController();
  final motherPhone = TextEditingController();
  final motherEmail = TextEditingController();
  final motherOccupation = TextEditingController();
  final motherJobTitle = TextEditingController();
  final motherCompany = TextEditingController();
  final motherWorkPhone = TextEditingController();
  final motherAddress = TextEditingController();

  final fatherName = TextEditingController();
  final fatherPhone = TextEditingController();
  final fatherEmail = TextEditingController();
  final fatherOccupation = TextEditingController();
  final fatherJobTitle = TextEditingController();
  final fatherCompany = TextEditingController();
  final fatherWorkPhone = TextEditingController();
  final fatherAddress = TextEditingController();

  final emergencyName = TextEditingController();
  final emergencyRelationship = TextEditingController();
  final emergencyPhone = TextEditingController();

  final signature = TextEditingController();

  List<TextEditingController> get _all => [
        childName, dob, enrolDate, nationality, religion, homeAddress,
        motherName, motherPhone, motherEmail, motherOccupation, motherJobTitle,
        motherCompany, motherWorkPhone, motherAddress,
        fatherName, fatherPhone, fatherEmail, fatherOccupation, fatherJobTitle,
        fatherCompany, fatherWorkPhone, fatherAddress,
        emergencyName, emergencyRelationship, emergencyPhone,
        signature,
      ];

  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
  }
}

/// Keeps a PageView child's element (and every TextFormField in it) alive
/// while it is off-screen, so half-typed input is never rebuilt away.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.labels,
    required this.currentStep,
    required this.onStepTapped,
  });

  final List<String> labels;
  final int currentStep;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: i <= currentStep
                    ? AppColors.leafGreen
                    : palette.divider,
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
  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Column(
        children: [
          CircleAvatar(
            radius: (16 * scale).r,
            backgroundColor: isActive
                ? AppColors.leafGreen
                : (isDone
                      ? AppColors.leafGreen.withValues(alpha: 0.15)
                      : palette.chip),
            child: isDone
                ? Icon(
                    Icons.check,
                    size: (16 * scale).w,
                    color: AppColors.leafGreen,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: (13 * scale).sp,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : palette.textTertiary,
                    ),
                  ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: (11 * scale).sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.leafGreen : palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
