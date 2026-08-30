import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/kid_photo_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/child_profile_cubit.dart';
import '../../data/repositories/children_repository.dart';
import 'emergency_contact_dialog.dart';
import '../screens/child_edit_pager.dart';

/// Left column of the child profile screen — the old read-only profile card
/// rebuilt as stacked sub-cards, each wired to a live `Admin Children`
/// endpoint through [ChildProfileCubit].
class ChildManageColumn extends StatelessWidget {
  const ChildManageColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChildProfileCubit, ChildProfileState>(
      listenWhen: (_, curr) => curr is ChildProfileLoaded && curr.error != null,
      listener: (context, state) {
        final error = (state as ChildProfileLoaded).error;
        if (error != null) AppSnackbar.showError(context, error.message.tr());
      },
      builder: (context, state) {
        if (state is ChildProfileLoading || state is ChildProfileInitial) {
          return _SubCard(
            child: SizedBox(
              height: 200.h,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is ChildProfileError) {
          return _SubCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 36.w, color: context.palette.dangerText),
                SizedBox(height: 12.h),
                Text(state.exception.message.tr(),
                    textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: () =>
                      context.read<ChildProfileCubit>().load(),
                  child: Text('settings_profile_retry'.tr()),
                ),
              ],
            ),
          );
        }

        final loaded = state as ChildProfileLoaded;
        final child = loaded.child;
        final busy = loaded.mutating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileCard(child: child, busy: busy),
            SizedBox(height: 20.h),
            _IdentityCard(child: child),
            SizedBox(height: 20.h),
            _ParentsCard(child: child),
            SizedBox(height: 20.h),
            _AllergiesCard(child: child),
            SizedBox(height: 20.h),
            _EmergencyCard(child: child, busy: busy),
            SizedBox(height: 20.h),
            _QrCard(child: child, busy: busy),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Profile — photo, name, age, status, roster switch, edit
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child, required this.busy});

  final Child child;
  final bool busy;

  Future<void> _pickPhoto(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    await context.read<ChildProfileCubit>().uploadPhoto(path);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<ChildProfileCubit>();
    return _SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                    bottomLeft: Radius.circular(8.r),
                  ),
                  child: SizedBox(
                    width: 150.w,
                    height: 150.w,
                    child: child.photoUrl.isEmpty
                        ? Container(
                            color: AppColors.surfaceSage,
                            child: Icon(Icons.person,
                                size: 60.w, color: palette.brandText))
                        : Image(
                            image: kidPhotoProvider(child.photoUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.surfaceSage,
                              child: Icon(Icons.person,
                                  size: 60.w, color: palette.brandText),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: 4.w,
                  bottom: 4.w,
                  child: PopupMenuButton<String>(
                    enabled: !busy,
                    tooltip: 'child_details_photo_replace'.tr(),
                    icon: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.card, width: 3.w),
                      ),
                      child: Icon(Icons.camera_alt,
                          size: 13.w, color: palette.card),
                    ),
                    onSelected: (v) {
                      if (v == 'replace') _pickPhoto(context);
                      if (v == 'remove') cubit.deletePhoto();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'replace',
                          child: Text('child_details_photo_replace'.tr())),
                      if (child.photoUrl.isNotEmpty)
                        PopupMenuItem(
                            value: 'remove',
                            child: Text('child_details_photo_remove'.tr())),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: Text(
              child.fullName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: AppFonts.jakarta,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary),
            ),
          ),
          if (child.ageYears != null) ...[
            SizedBox(height: 4.h),
            Center(
              child: Text(
                'child_profile_age_label'
                    .tr(namedArgs: {'age': '${child.ageYears}'}),
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary),
              ),
            ),
          ],
          SizedBox(height: 20.h),
          Text('child_details_status_label'.tr(),
              style:
                  TextStyle(fontSize: 12.sp, color: palette.textSecondary)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final s in ChildStatus.values)
                ChoiceChip(
                  label: Text('child_status_${s.name}'.tr()),
                  selected: s == child.status,
                  onSelected: busy
                      ? null
                      : (sel) {
                          if (sel && s != child.status) cubit.setStatus(s);
                        },
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('child_details_roster_label'.tr(),
                        style: TextStyle(
                            fontSize: 12.sp, color: palette.textPrimary)),
                    Text('child_details_roster_hint'.tr(),
                        style: TextStyle(
                            fontSize: 10.sp, color: palette.textTertiary)),
                  ],
                ),
              ),
              Switch(
                value: child.isActive,
                onChanged:
                    busy ? null : (v) => cubit.setActive(isActive: v),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: ChildEditPager(child: child),
                          ),
                        ),
                      ),
              icon: Icon(Icons.edit_outlined, size: 16.w),
              label: Text('child_details_edit_full'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Identity — read-only rows
// ---------------------------------------------------------------------------

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.child});
  final Child child;

  @override
  Widget build(BuildContext context) {
    return _SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'child_details_section_identity'.tr()),
          SizedBox(height: 14.h),
          _kv(context, 'child_details_nationality'.tr(), child.nationality),
          _kv(context, 'child_details_religion'.tr(), child.religion),
          _kv(context, 'child_details_home_address'.tr(), child.homeAddress),
          _kv(
            context,
            'child_details_enrol_date'.tr(),
            child.enrollmentDate == null
                ? '—'
                : _dmy(child.enrollmentDate!),
            last: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Parents
// ---------------------------------------------------------------------------

class _ParentsCard extends StatelessWidget {
  const _ParentsCard({required this.child});
  final Child child;

  @override
  Widget build(BuildContext context) {
    return _SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'child_details_section_parents'.tr()),
          SizedBox(height: 14.h),
          _ParentBlock(title: 'child_details_mother'.tr(), parent: child.mother),
          SizedBox(height: 12.h),
          _ParentBlock(title: 'child_details_father'.tr(), parent: child.father),
        ],
      ),
    );
  }
}

class _ParentBlock extends StatelessWidget {
  const _ParentBlock({required this.title, required this.parent});
  final String title;
  final ParentContact? parent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final p = parent;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: palette.sand, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: palette.amberText)),
          SizedBox(height: 8.h),
          if (p == null || p.isEmpty)
            Text('child_details_not_provided'.tr(),
                style:
                    TextStyle(fontSize: 12.sp, color: palette.textSecondary))
          else ...[
            Text(p.fullName.isEmpty ? '—' : p.fullName,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary)),
            if (p.phone.isNotEmpty)
              Text(p.phone,
                  style: TextStyle(
                      fontSize: 12.sp, color: palette.textSecondary)),
            if (p.email.isNotEmpty)
              Text(p.email,
                  style: TextStyle(
                      fontSize: 12.sp, color: palette.textSecondary)),
            if (p.occupation.isNotEmpty || p.companyName.isNotEmpty)
              Text(
                  [p.occupation, p.companyName]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: TextStyle(
                      fontSize: 12.sp, color: palette.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Allergies
// ---------------------------------------------------------------------------

class _AllergiesCard extends StatelessWidget {
  const _AllergiesCard({required this.child});
  final Child child;

  List<String> get _items {
    final raw = child.allergies;
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = _items;
    return _SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'child_profile_allergies_label'.tr()),
          SizedBox(height: 12.h),
          if (items.isEmpty)
            Text('child_details_none'.tr(),
                style:
                    TextStyle(fontSize: 12.sp, color: palette.textSecondary))
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final a in items)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                        color: AppColors.peachTint,
                        borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded,
                            size: 12.w, color: AppColors.allergyTagText),
                        SizedBox(width: 6.w),
                        Text(a,
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.allergyTagText)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emergency contacts — inline add / remove
// ---------------------------------------------------------------------------

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.child, required this.busy});
  final Child child;
  final bool busy;

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<ChildProfileCubit>();
    final contact = await showDialog<NewEmergencyContact>(
      context: context,
      builder: (_) => const EmergencyContactDialog(),
    );
    if (contact != null) await cubit.addEmergencyContact(contact);
  }

  Future<void> _remove(BuildContext context, ChildEmergencyContact c) async {
    final cubit = context.read<ChildProfileCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('child_details_contact_remove_title'.tr()),
        content: Text('child_details_contact_remove_body'
            .tr(namedArgs: {'name': c.name})),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('action_cancel'.tr())),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('child_details_contact_remove_confirm'.tr())),
        ],
      ),
    );
    if (ok == true) await cubit.removeEmergencyContact(c.id);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _label(
                      context, 'child_details_emergency_title'.tr())),
              TextButton.icon(
                onPressed: busy ? null : () => _add(context),
                icon: Icon(Icons.add, size: 16.w),
                label: Text('child_details_contact_add'.tr()),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          if (child.emergencyContacts.isEmpty)
            Text('child_details_emergency_empty'.tr(),
                style:
                    TextStyle(fontSize: 12.sp, color: palette.textSecondary))
          else
            for (final c in child.emergencyContacts)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                          color: palette.chip, shape: BoxShape.circle),
                      child: Icon(Icons.person,
                          size: 15.w, color: palette.textSecondary),
                    ),
                    SizedBox(width: 12.w),
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
                                  fontSize: 11.sp,
                                  color: palette.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: busy ? null : () => _remove(context, c),
                      icon: Icon(Icons.delete_outline,
                          size: 18.w, color: palette.dangerText),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR / scan code
// ---------------------------------------------------------------------------

class _QrCard extends StatelessWidget {
  const _QrCard({required this.child, required this.busy});
  final Child child;
  final bool busy;

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('child_details_regen_title'.tr()),
        content: Text('child_details_regen_body'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('action_cancel'.tr())),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('child_details_regen_confirm'.tr())),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<ChildProfileCubit>().regenerateScanCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _SubCard(
      color: palette.cardMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(16.r)),
                child: child.scanCode.isEmpty
                    ? Icon(Icons.qr_code_2, size: 48.w, color: palette.divider)
                    : QrImageView(data: child.scanCode, backgroundColor: Colors.white),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('child_profile_qr_title'.tr(),
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary)),
                    SizedBox(height: 4.h),
                    Text('child_profile_qr_subtitle'.tr(),
                        style: TextStyle(
                            fontSize: 11.sp, color: palette.textSecondary)),
                    SizedBox(height: 6.h),
                    SelectableText(
                      child.scanCode.isEmpty ? '—' : child.scanCode,
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _confirm(context),
              icon: Icon(Icons.refresh, size: 16.w),
              label: Text('child_details_regen_button'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// shared bits
// ---------------------------------------------------------------------------

class _SubCard extends StatelessWidget {
  const _SubCard({required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: color ?? context.palette.card,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: child,
      );
}

Widget _label(BuildContext context, String text) => Text(
      text.toUpperCase(),
      style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: context.palette.textSecondary),
    );

Widget _kv(BuildContext context, String k, String v, {bool last = false}) {
  final palette = context.palette;
  return Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 12.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k.toUpperCase(),
            style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: palette.textTertiary)),
        SizedBox(height: 2.h),
        Text(v.isEmpty ? '—' : v,
            style: TextStyle(fontSize: 13.sp, color: palette.textPrimary)),
      ],
    ),
  );
}

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
