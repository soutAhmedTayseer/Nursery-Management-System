import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../registration/presentation/widgets/agreement_section.dart';
import '../../../registration/presentation/widgets/allergies_section.dart';
import '../../../registration/presentation/widgets/emergency_contact_section.dart';
import '../../../registration/presentation/widgets/registration_form_section.dart';
import '../../../registration/presentation/widgets/registration_input_field.dart';
import '../../data/repositories/children_repository.dart';
import '../widgets/emergency_contact_dialog.dart';
import '../cubit/child_profile_cubit.dart';

/// Edits a child through the same 5-step shell as Registration
/// (Child · Mother · Father · Emergency · Agreement), pre-filled from [child].
///
/// Steps 0-2 and 4 build one `PUT /api/children/{id}` on Save. Step 3 manages
/// the emergency-contact list live through its own endpoints, so those changes
/// persist immediately and independently of Save.
class ChildEditPager extends StatefulWidget {
  const ChildEditPager({super.key, required this.child});

  final Child child;

  @override
  State<ChildEditPager> createState() => _ChildEditPagerState();
}

class _ChildEditPagerState extends State<ChildEditPager> {
  static const _stepCount = 5;

  final _pageController = PageController();
  int _currentStep = 0;
  bool _submitting = false;

  late final _c = _EditControllers.fromChild(widget.child);
  late bool _mediaPermission =
      widget.child.agreement?.mediaPermission ?? false;
  late bool _acceptedTerms = widget.child.agreement?.acceptedTerms ?? false;
  late List<String> _allergies = (widget.child.allergies ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  final _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());

  @override
  void dispose() {
    _pageController.dispose();
    _c.dispose();
    super.dispose();
  }

  ChildProfileCubit get _cubit => context.read<ChildProfileCubit>();

  DateTime? _parseDmy(String raw) {
    final p = raw.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]), m = int.tryParse(p[1]), y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  List<String> get _fatherValues =>
      _c.father.all.map((c) => c.text.trim()).toList();
  bool get _fatherAnyFilled => _fatherValues.any((v) => v.isNotEmpty);
  bool get _fatherAllFilled => _fatherValues.every((v) => v.isNotEmpty);

  void _jumpTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  /// Forward moves validate every step skipped over; back moves are free.
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
            context, 'registration_father_all_or_none_error'.tr());
        _jumpTo(2);
        return;
      }
    }
    _jumpTo(target);
  }

  void _next() {
    if (_currentStep < _stepCount - 1) {
      _goToStep(_currentStep + 1);
      return;
    }
    for (var i = 0; i < _stepCount; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? true)) {
        _jumpTo(i);
        return;
      }
    }
    if (_fatherAnyFilled && !_fatherAllFilled) {
      AppSnackbar.showError(
          context, 'registration_father_all_or_none_error'.tr());
      _jumpTo(2);
      return;
    }
    final dob = _parseDmy(_c.dob.text);
    final enrol = _parseDmy(_c.enrol.text);
    if (dob == null || enrol == null) {
      AppSnackbar.showError(context, 'registration_error_required'.tr());
      _jumpTo(0);
      return;
    }
    setState(() => _submitting = true);
    _cubit.updateChild(ChildInput(
      fullName: _c.name.text.trim(),
      dateOfBirth: dob,
      enrollmentDate: enrol,
      nationality: _c.nationality.text.trim(),
      religion: _c.religion.text.trim(),
      homeAddress: _c.homeAddress.text.trim(),
      allergies: _allergies.isEmpty ? null : _allergies.join(', '),
      mother: _c.mother.toContact(),
      father: _c.father.toContact(),
      agreement: ChildAgreement(
        mediaPermission: _mediaPermission,
        parentSignature: _c.signature.text.trim(),
        signedDate: widget.child.agreement?.signedDate ?? DateTime.now(),
        acceptedTerms: _acceptedTerms,
      ),
    ));
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

    return BlocListener<ChildProfileCubit, ChildProfileState>(
      listenWhen: (_, curr) => curr is ChildProfileLoaded,
      listener: (context, state) {
        final s = state as ChildProfileLoaded;
        if (s.mutating) return;
        if (s.error != null) {
          if (_submitting) setState(() => _submitting = false);
          return;
        }
        if (_submitting) {
          AppSnackbar.showSuccess(context, 'child_edit_saved'.tr());
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: palette.page,
        appBar: AppBar(
          backgroundColor: palette.page,
          elevation: 0,
          title: Text('child_edit_title'.tr()),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.pagePadding, vertical: spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(
                  labels: stepLabels,
                  currentStep: _currentStep,
                  onStepTapped: _goToStep,
                ),
                SizedBox(height: spacing.xl),
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
                        controller: _pageController,
                        onPageChanged: (i) =>
                            setState(() => _currentStep = i),
                        children: [
                          for (var i = 0; i < _stepCount; i++)
                            _KeepAlivePage(
                              child: Form(
                                key: _formKeys[i],
                                child: SingleChildScrollView(
                                    child: _stepBody(i, spacing)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.lg),
                _Footer(
                  currentStep: _currentStep,
                  stepCount: _stepCount,
                  submitting: _submitting,
                  onBack: () => _goToStep(_currentStep - 1),
                  onNext: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody(int i, AppSpacing spacing) {
    switch (i) {
      case 0:
        return RegistrationFormSection(
          title: 'registration_section_child'.tr(),
          icon: Icons.face_retouching_natural,
          accentColor: AppColors.accentGreen,
          children: [
            _field('registration_label_child_name', 'registration_hint_child_name',
                _c.name, RegistrationFieldInputType.letters, true),
            SizedBox(height: spacing.lg),
            _field('registration_label_dob', 'registration_hint_date', _c.dob,
                RegistrationFieldInputType.date, true),
            SizedBox(height: spacing.lg),
            _field('registration_label_enrol_date', 'registration_hint_date',
                _c.enrol, RegistrationFieldInputType.date, true),
            SizedBox(height: spacing.lg),
            _field('registration_label_nationality',
                'registration_hint_nationality', _c.nationality,
                RegistrationFieldInputType.letters, true),
            SizedBox(height: spacing.lg),
            _field('registration_label_religion', 'registration_hint_religion',
                _c.religion, RegistrationFieldInputType.letters, true),
            SizedBox(height: spacing.lg),
            _field('registration_label_home_address',
                'registration_hint_home_address', _c.homeAddress,
                RegistrationFieldInputType.alphanumeric, true),
            SizedBox(height: spacing.lg),
            AllergiesSection(
              initialAllergies: _allergies,
              onChanged: (v) => _allergies = v,
            ),
          ],
        );
      case 1:
        return RegistrationFormSection(
          title: 'registration_section_mother'.tr(),
          icon: Icons.female_rounded,
          accentColor: AppColors.bronze,
          children: _parentFields(_c.mother, required: true, spacing: spacing),
        );
      case 2:
        return RegistrationFormSection(
          title: 'registration_section_father'.tr(),
          icon: Icons.male_rounded,
          accentColor: context.palette.textSecondary,
          children: [
            Text('registration_father_optional_hint'.tr(),
                style: TextStyle(
                    fontSize: (12 * context.uiScale).sp,
                    color: context.palette.textTertiary,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: spacing.lg),
            ..._parentFields(_c.father, required: false, spacing: spacing),
          ],
        );
      case 3:
        return _EmergencyStep();
      case 4:
        return AgreementSection(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('registration_agreement_media_release_label'.tr()),
              value: _mediaPermission,
              onChanged: (v) => setState(() => _mediaPermission = v),
            ),
            SizedBox(height: spacing.md),
            _field('registration_agreement_signature_label',
                'registration_agreement_signature_hint', _c.signature,
                RegistrationFieldInputType.letters, true),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _acceptedTerms,
              onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
              title: Text('registration_agreement_checkbox_label'.tr()),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _field(String label, String hint, TextEditingController c,
          RegistrationFieldInputType type, bool required) =>
      RegistrationInputField(
        label: label.tr(),
        hint: hint.tr(),
        inputType: type,
        controller: c,
        required: required,
      );

  List<Widget> _parentFields(_ParentControllers p,
      {required bool required, required AppSpacing spacing}) {
    final specs = <(String, String, TextEditingController, RegistrationFieldInputType)>[
      ('child_edit_parent_name', 'registration_hint_parent_name', p.name,
          RegistrationFieldInputType.letters),
      ('registration_label_mother_phone', 'registration_hint_phone', p.phone,
          RegistrationFieldInputType.digits),
      ('registration_label_contact_email', 'registration_hint_email', p.email,
          RegistrationFieldInputType.email),
      ('registration_label_occupation', 'registration_hint_occupation',
          p.occupation, RegistrationFieldInputType.letters),
      ('registration_label_job_title', 'registration_hint_job_title',
          p.jobTitle, RegistrationFieldInputType.letters),
      ('registration_label_company_name', 'registration_hint_company_name',
          p.company, RegistrationFieldInputType.alphanumeric),
      ('registration_label_work_phone', 'registration_hint_work_phone',
          p.workPhone, RegistrationFieldInputType.digits),
      ('registration_label_address_alt', 'registration_hint_workplace_alt',
          p.address, RegistrationFieldInputType.alphanumeric),
    ];
    final out = <Widget>[];
    for (var i = 0; i < specs.length; i++) {
      if (i > 0) out.add(SizedBox(height: spacing.lg));
      final (l, h, ctrl, t) = specs[i];
      out.add(_field(l, h, ctrl, t, required));
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// Emergency step — live add/remove against the emergency-contact endpoints
// ---------------------------------------------------------------------------

class _EmergencyStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<ChildProfileCubit, ChildProfileState>(
      builder: (context, state) {
        final loaded = state is ChildProfileLoaded ? state : null;
        final contacts = loaded?.child.emergencyContacts ?? const [];
        final busy = loaded?.mutating ?? false;
        return EmergencyContactSection(
          children: [
            if (contacts.isEmpty)
              Text('child_details_emergency_empty'.tr(),
                  style: TextStyle(
                      fontSize: 13.sp, color: palette.textSecondary))
            else
              for (final c in contacts)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(16.r)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: palette.textPrimary)),
                              Text('${c.relationship} · ${c.phone}',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: palette.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: busy
                              ? null
                              : () => context
                                  .read<ChildProfileCubit>()
                                  .removeEmergencyContact(c.id),
                          icon: Icon(Icons.delete_outline,
                              size: 18.w, color: palette.dangerText),
                        ),
                      ],
                    ),
                  ),
                ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final contact = await showDialog<NewEmergencyContact>(
                        context: context,
                        builder: (_) => const EmergencyContactDialog(),
                      );
                      if (contact != null && context.mounted) {
                        await context
                            .read<ChildProfileCubit>()
                            .addEmergencyContact(contact);
                      }
                    },
              icon: Icon(Icons.add, size: 16.w),
              label: Text('child_details_contact_add'.tr()),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// footer + step indicator (mirrors RegistrationScreen)
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({
    required this.currentStep,
    required this.stepCount,
    required this.submitting,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final int stepCount;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spacing = AppSpacing.of(context);
    final scale = context.uiScale;
    final isLast = currentStep == stepCount - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: currentStep > 0 ? onBack : null,
          child: Text('registration_back'.tr(),
              style: TextStyle(
                  fontSize: (14 * scale).sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textSecondary,
                  letterSpacing: 1.5)),
        ),
        Text(
          'registration_step_of'.tr(args: ['${currentStep + 1}', '$stepCount']),
          style: TextStyle(
              fontSize: (13 * scale).sp,
              color: palette.textTertiary,
              fontWeight: FontWeight.w600),
        ),
        ElevatedButton(
          onPressed: submitting ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.leafGreen,
            padding: EdgeInsets.symmetric(
                horizontal: spacing.xl, vertical: spacing.md * scale),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r)),
            elevation: 0,
          ),
          child: submitting
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  isLast ? 'child_edit_save'.tr() : 'registration_next'.tr(),
                  style: TextStyle(
                      fontSize: (16 * scale).sp,
                      fontWeight: FontWeight.bold,
                      color: palette.card),
                ),
        ),
      ],
    );
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
                color:
                    i <= currentStep ? AppColors.leafGreen : palette.divider,
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
                ? Icon(Icons.check,
                    size: (16 * scale).w, color: AppColors.leafGreen)
                : Text('${index + 1}',
                    style: TextStyle(
                        fontSize: (13 * scale).sp,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : palette.textTertiary)),
          ),
          SizedBox(height: 6.h),
          Text(label,
              style: TextStyle(
                  fontSize: (11 * scale).sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color:
                      isActive ? AppColors.leafGreen : palette.textTertiary)),
        ],
      ),
    );
  }
}

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

// ---------------------------------------------------------------------------
// controllers
// ---------------------------------------------------------------------------

class _ParentControllers {
  _ParentControllers(ParentContact? p)
      : name = TextEditingController(text: p?.fullName ?? ''),
        phone = TextEditingController(text: p?.phone ?? ''),
        email = TextEditingController(text: p?.email ?? ''),
        occupation = TextEditingController(text: p?.occupation ?? ''),
        jobTitle = TextEditingController(text: p?.jobTitle ?? ''),
        company = TextEditingController(text: p?.companyName ?? ''),
        workPhone = TextEditingController(text: p?.workPhone ?? ''),
        address = TextEditingController(text: p?.address ?? '');

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController occupation;
  final TextEditingController jobTitle;
  final TextEditingController company;
  final TextEditingController workPhone;
  final TextEditingController address;

  List<TextEditingController> get all =>
      [name, phone, email, occupation, jobTitle, company, workPhone, address];

  ParentContact toContact() => ParentContact(
        fullName: name.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        occupation: occupation.text.trim(),
        jobTitle: jobTitle.text.trim(),
        companyName: company.text.trim(),
        workPhone: workPhone.text.trim(),
        address: address.text.trim(),
      );

  void dispose() {
    for (final c in all) {
      c.dispose();
    }
  }
}

class _EditControllers {
  _EditControllers._({
    required this.name,
    required this.dob,
    required this.enrol,
    required this.nationality,
    required this.religion,
    required this.homeAddress,
    required this.signature,
    required this.mother,
    required this.father,
  });

  factory _EditControllers.fromChild(Child c) {
    String dmy(DateTime? d) => d == null
        ? ''
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return _EditControllers._(
      name: TextEditingController(text: c.fullName),
      dob: TextEditingController(text: dmy(c.dateOfBirth)),
      enrol: TextEditingController(text: dmy(c.enrollmentDate)),
      nationality: TextEditingController(text: c.nationality),
      religion: TextEditingController(text: c.religion),
      homeAddress: TextEditingController(text: c.homeAddress),
      signature: TextEditingController(text: c.agreement?.parentSignature ?? ''),
      mother: _ParentControllers(c.mother),
      father: _ParentControllers(c.father),
    );
  }

  final TextEditingController name;
  final TextEditingController dob;
  final TextEditingController enrol;
  final TextEditingController nationality;
  final TextEditingController religion;
  final TextEditingController homeAddress;
  final TextEditingController signature;
  final _ParentControllers mother;
  final _ParentControllers father;

  void dispose() {
    for (final c in [
      name,
      dob,
      enrol,
      nationality,
      religion,
      homeAddress,
      signature,
    ]) {
      c.dispose();
    }
    mother.dispose();
    father.dispose();
  }
}
