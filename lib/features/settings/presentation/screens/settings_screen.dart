import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/l10n/api_error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../account/data/models/account.dart';
import '../../../account/presentation/cubit/account_cubit.dart';
import '../../data/app_settings.dart';
import '../cubit/app_settings_cubit.dart';
import '../widgets/settings_section.dart';
import 'data_export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final palette = context.palette;

    return BlocBuilder<AppSettingsCubit, AppSettings>(
      builder: (context, settings) {
        return Scaffold(
          backgroundColor: palette.page,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.pagePadding),
            child: Center(
              // Settings rows read badly at full desktop width — the label
              // and its control end up a screen apart.
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings_title'.tr(),
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: palette.textPrimary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'settings_subtitle'.tr(),
                      style: TextStyle(fontSize: 13.sp, color: palette.textTertiary),
                    ),
                    SizedBox(height: spacing.xl),
                    _AppearanceSection(settings: settings),
                    SizedBox(height: spacing.lg),
                    _ProfileSection(settings: settings),
                    SizedBox(height: spacing.lg),
                    _NurserySection(settings: settings),
                    SizedBox(height: spacing.lg),
                    const _DataSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A SegmentedButton label that ellipsizes instead of wrapping — its default
/// Text wraps to a second line under pressure, which on a single Arabic word
/// ("النظام") reads as the word breaking apart rather than an overflow.
Widget _segmentLabel(String text) => Text(text, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis);

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppSettingsCubit>();
    return SettingsSection(
      title: 'settings_appearance_title'.tr(),
      icon: Icons.palette_outlined,
      children: [
        SettingsTile(
          label: 'settings_theme_label'.tr(),
          description: 'settings_theme_description'.tr(),
          // A SegmentedButton doesn't shrink its own labels — squeezed into
          // three icon+text segments on a narrow settings pane, "النظام"
          // (System) was wrapping across two lines instead of ellipsizing.
          // Scrollable so a truly tight width scrolls the control rather
          // than compressing it, and each label is forced to one line so a
          // long Arabic word breaks to "…" instead of splitting mid-word.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: _segmentLabel('settings_theme_light'.tr()),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: _segmentLabel('settings_theme_dark'.tr()),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: _segmentLabel('settings_theme_system'.tr()),
                ),
              ],
              selected: {settings.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => cubit.setThemeMode(selection.first),
            ),
          ),
        ),
        SettingsTile(
          label: 'settings_language_label'.tr(),
          description: 'settings_language_description'.tr(),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: _segmentLabel('settings_language_en'.tr())),
              ButtonSegment(value: 'ar', label: _segmentLabel('settings_language_ar'.tr())),
            ],
            selected: {context.locale.languageCode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => context.setLocale(Locale(selection.first)),
          ),
        ),
        SettingsTile(
          label: 'settings_text_size_label'.tr(),
          description: 'settings_text_size_description'.tr(),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: settings.textScale,
                  min: 0.85,
                  max: 1.3,
                  divisions: 9,
                  label: '${(settings.textScale * 100).round()}%',
                  onChanged: cubit.setTextScale,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(settings.textScale * 100).round()}%',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.palette.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Admin profile, backed by the app-wide `AccountCubit` (live
/// `GET/PUT /api/account/me` + `PUT /api/account/password`). The profile
/// photo has no endpoint yet, so it stays a local `AppSettingsCubit`
/// preference (see the linking open-issues doc).
class _ProfileSection extends StatefulWidget {
  const _ProfileSection({required this.settings});

  final AppSettings settings;

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  @override
  void initState() {
    super.initState();
    // Usually already loaded by splash/login; covers a cold open straight
    // into Settings, or a retry after logout reset.
    final cubit = context.read<AccountCubit>();
    if (cubit.state is AccountInitial) cubit.load();
  }

  AppSettings get settings => widget.settings;

  Future<void> _pickPhoto(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    await context.read<AppSettingsCubit>().setPhotoPath(path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listenWhen: (_, current) => current is AccountError,
      listener: (context, state) {
        if (state is AccountError) {
          AppSnackbar.showError(context, apiErrorMessage(state.exception));
        }
      },
      builder: (context, state) {
        return SettingsSection(
          title: 'settings_profile_title'.tr(),
          icon: Icons.person_outline,
          accent: AppColors.gold,
          children: _children(context, state),
        );
      },
    );
  }

  List<Widget> _children(BuildContext context, AccountState state) {
    if (state is AccountLoaded) return _loaded(context, state.account);
    if (state is AccountError) {
      return [
        _StatusRow(
          message: 'settings_profile_load_error'.tr(),
          actionLabel: 'settings_profile_retry'.tr(),
          onAction: () => context.read<AccountCubit>().load(),
        ),
      ];
    }
    return [_StatusRow(message: 'settings_profile_loading'.tr())];
  }

  List<Widget> _loaded(BuildContext context, Account account) {
    final palette = context.palette;
    final photo = settings.adminPhotoPath;
    final cubit = context.read<AccountCubit>();
    return [
      Row(
        children: [
          GestureDetector(
            onTap: () => _pickPhoto(context),
            child: CircleAvatar(
              radius: 32.r,
              backgroundColor: palette.chip,
              backgroundImage: photo == null ? null : FileImage(File(photo)),
              child: photo != null ? null : Icon(Icons.person, size: 30.w, color: palette.textTertiary),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.fullName,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
                ),
                Text(
                  account.userName,
                  style: TextStyle(fontSize: 12.sp, color: palette.textTertiary),
                ),
                SizedBox(height: 6.h),
                Text(
                  'settings_profile_photo_hint'.tr(),
                  style: TextStyle(fontSize: 11.sp, color: palette.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
      _ProfileEditForm(account: account),
      SettingsTile(
        label: 'settings_profile_username_label'.tr(),
        child: _ReadOnlyValue(account.userName),
      ),
      SettingsTile(
        label: 'settings_profile_role_label'.tr(),
        child: _ReadOnlyValue(account.role.isEmpty
            ? 'settings_profile_not_set'.tr()
            : account.role),
      ),
      SettingsTile(
        label: 'settings_password_label'.tr(),
        description: 'settings_password_description'.tr(),
        child: OutlinedButton.icon(
          onPressed: () => _openPasswordDialog(context, cubit),
          icon: Icon(Icons.lock_outline, size: 16.w),
          label: Text('settings_password_action'.tr()),
        ),
      ),
    ];
  }

  Future<void> _openPasswordDialog(BuildContext context, AccountCubit cubit) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var submitting = false;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('settings_password_dialog_title'.tr()),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'settings_password_current_label'.tr()),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'settings_password_required'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'settings_password_new_label'.tr()),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'settings_password_too_short'.tr() : null,
                ),
                if (errorText != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    errorText!,
                    style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
              child: Text('settings_password_cancel'.tr()),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        submitting = true;
                        errorText = null;
                      });
                      try {
                        await cubit.changePassword(
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        if (context.mounted) {
                          AppSnackbar.showSuccess(context, 'settings_password_changed'.tr());
                        }
                      } on ApiException catch (e) {
                        setState(() {
                          submitting = false;
                          errorText = apiErrorMessage(e);
                        });
                      } catch (_) {
                        setState(() {
                          submitting = false;
                          errorText = 'error_generic'.tr();
                        });
                      }
                    },
              child: Text('settings_password_submit'.tr()),
            ),
          ],
        ),
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
  }
}

/// Editable full name + phone with a single Save button that does one
/// `PUT /api/account/me` for both fields.
class _ProfileEditForm extends StatefulWidget {
  const _ProfileEditForm({required this.account});

  final Account account;

  @override
  State<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<_ProfileEditForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.account.fullName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.account.phoneNumber ?? '');
  bool _saving = false;

  String get _savedName => widget.account.fullName;
  String get _savedPhone => widget.account.phoneNumber ?? '';

  bool get _dirty =>
      _name.text.trim() != _savedName || _phone.text.trim() != _savedPhone;

  @override
  void didUpdateWidget(covariant _ProfileEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-seed after a successful save (or an external refresh) — but not while
    // the admin is still editing an unsaved change.
    if (!_dirty) {
      if (_name.text != _savedName) _name.text = _savedName;
      if (_phone.text != _savedPhone) _phone.text = _savedPhone;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      AppSnackbar.showError(context, 'settings_profile_name_required'.tr());
      return;
    }
    setState(() => _saving = true);
    await context.read<AccountCubit>().save(
          fullName: name,
          phoneNumber: _phone.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    // save() emits AccountError on failure (surfaced by the section listener);
    // a matching AccountLoaded means it went through.
    final state = context.read<AccountCubit>().state;
    if (state is AccountLoaded && state.account.fullName == name) {
      AppSnackbar.showSuccess(context, 'settings_profile_saved'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          label: 'settings_admin_name_label'.tr(),
          // The audit log stamps this name against every settled invoice,
          // so it needs to identify a person, not say "Admin".
          description: 'settings_admin_name_description'.tr(),
          child: TextField(
            controller: _name,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
        Divider(height: 28.h, color: context.palette.divider),
        SettingsTile(
          label: 'settings_profile_phone_label'.tr(),
          child: TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            onPressed: (!_dirty || _saving) ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.save_outlined, size: 16.w),
            label: Text('settings_profile_save'.tr()),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        value,
        style: TextStyle(fontSize: 13.sp, color: context.palette.textSecondary),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 13.sp, color: context.palette.textTertiary),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _NurserySection extends StatelessWidget {
  const _NurserySection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppSettingsCubit>();
    return SettingsSection(
      title: 'settings_nursery_title'.tr(),
      icon: Icons.home_work_outlined,
      accent: AppColors.subscriptionBrown,
      children: [
        SettingsTile(
          label: 'settings_nursery_name_label'.tr(),
          child: _InlineTextField(
            value: settings.nurseryName,
            onSubmitted: (value) => cubit.updateNursery(name: value),
          ),
        ),
        SettingsTile(
          label: 'settings_capacity_label'.tr(),
          description: 'settings_capacity_description'.tr(),
          child: _InlineTextField(
            value: '${settings.capacity}',
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) cubit.updateNursery(capacity: parsed);
            },
          ),
        ),
        SettingsTile(
          label: 'settings_overtime_rate_label'.tr(),
          description: 'settings_overtime_rate_description'.tr(),
          child: _InlineTextField(
            value: settings.overtimeHourlyRate.toStringAsFixed(0),
            keyboardType: TextInputType.number,
            suffixText: settings.currency,
            onSubmitted: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= 0) cubit.updateNursery(overtimeHourlyRate: parsed);
            },
          ),
        ),
        SettingsTile(
          label: 'settings_late_fine_label'.tr(),
          description: 'settings_late_fine_description'.tr(),
          child: _InlineTextField(
            value: settings.latePickupFine.toStringAsFixed(0),
            keyboardType: TextInputType.number,
            suffixText: settings.currency,
            onSubmitted: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= 0) cubit.updateNursery(latePickupFine: parsed);
            },
          ),
        ),
        SettingsTile(
          label: 'settings_late_grace_label'.tr(),
          description: 'settings_late_grace_description'.tr(),
          child: _InlineTextField(
            value: settings.latePickupGraceMinutes.toString(),
            keyboardType: TextInputType.number,
            suffixText: 'settings_minutes_suffix'.tr(),
            onSubmitted: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed >= 0) cubit.updateNursery(latePickupGraceMinutes: parsed);
            },
          ),
        ),
        SettingsTile(
          label: 'settings_currency_label'.tr(),
          child: _InlineTextField(
            value: settings.currency,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) cubit.updateNursery(currency: value.trim().toUpperCase());
            },
          ),
        ),
        SettingsTile(
          label: 'settings_hours_label'.tr(),
          description: 'settings_hours_description'.tr(),
          child: Row(
            children: [
              Expanded(
                child: _HourDropdown(
                  value: settings.openingHour,
                  onChanged: (hour) => cubit.updateNursery(openingHour: hour),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text('—', style: TextStyle(color: context.palette.textTertiary)),
              ),
              Expanded(
                child: _HourDropdown(
                  value: settings.closingHour,
                  onChanged: (hour) => cubit.updateNursery(closingHour: hour),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection();

  Future<void> _reset(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'settings_reset_confirm_title'.tr(),
      message: 'settings_reset_confirm_message'.tr(),
      confirmLabel: 'settings_reset_action'.tr(),
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AppSettingsCubit>().resetToDefaults();
    if (!context.mounted) return;
    AppSnackbar.showSuccess(context, 'settings_reset_done'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SettingsSection(
      title: 'settings_data_title'.tr(),
      icon: Icons.storage_outlined,
      accent: AppColors.penaltyOrange,
      children: [
        SettingsTile(
          label: 'settings_export_label'.tr(),
          description: 'settings_export_description'.tr(),
          child: OutlinedButton.icon(
            onPressed: () => exportAllDataCsv(context),
            icon: Icon(Icons.file_download_outlined, size: 16.w),
            label: Text('settings_export_action'.tr()),
          ),
        ),
        SettingsTile(
          label: 'settings_reset_label'.tr(),
          description: 'settings_reset_description'.tr(),
          child: OutlinedButton.icon(
            onPressed: () => _reset(context),
            style: OutlinedButton.styleFrom(foregroundColor: palette.dangerText),
            icon: Icon(Icons.restart_alt, size: 16.w),
            label: Text('settings_reset_action'.tr()),
          ),
        ),
        SettingsTile(
          label: 'settings_about_label'.tr(),
          child: Text(
            'settings_about_value'.tr(),
            style: TextStyle(fontSize: 13.sp, color: context.palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Text field that commits on submit or focus loss, so a value can't be
/// half-typed and silently dropped when the admin clicks elsewhere.
class _InlineTextField extends StatefulWidget {
  const _InlineTextField({
    required this.value,
    required this.onSubmitted,
    this.keyboardType,
    this.suffixText,
  });

  final String value;
  final ValueChanged<String> onSubmitted;
  final TextInputType? keyboardType;
  final String? suffixText;

  @override
  State<_InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<_InlineTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  late final FocusNode _focus = FocusNode()..addListener(_onFocusChange);

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && text != widget.value) widget.onSubmitted(text);
  }

  @override
  void didUpdateWidget(covariant _InlineTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync when the value changes elsewhere (e.g. a reset), but not
    // while the admin is mid-edit.
    if (widget.value != oldWidget.value && !_focus.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: widget.keyboardType,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (_) => _commit(),
      decoration: InputDecoration(
        isDense: true,
        suffixText: widget.suffixText,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }
}

class _HourDropdown extends StatelessWidget {
  const _HourDropdown({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
      items: [
        for (var hour = 0; hour < 24; hour++)
          DropdownMenuItem(value: hour, child: Text('${hour.toString().padLeft(2, '0')}:00')),
      ],
      onChanged: (hour) => hour == null ? null : onChanged(hour),
    );
  }
}
