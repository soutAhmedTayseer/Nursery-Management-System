import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/kid_photo_provider.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../../../core/theme/app_palette.dart';

/// Left-column profile card on the Child Profile Details screen: photo,
/// name, age, allergy chips, emergency contact, and QR — matches the Figma
/// "kids-nursery" child-profile screen.
class ChildProfileCard extends StatefulWidget {
  const ChildProfileCard({super.key, required this.childData});

  final KidSession childData;

  @override
  State<ChildProfileCard> createState() => _ChildProfileCardState();
}

class _ChildProfileCardState extends State<ChildProfileCard> {
  File? _pickedPhoto;

  int get _ageYears {
    final dob = widget.childData.kid.dateOfBirth;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  List<String> get _allergies {
    final raw = widget.childData.kid.allergies;
    if (raw == null || raw.trim().isEmpty) return [];
    return raw.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    setState(() => _pickedPhoto = File(path));
    // ponytail: no upload endpoint yet — persist the local path itself so
    // the Sessions grid picks it up too, instead of a real remote URL.
    unawaited(context.read<SessionsCubit>().updateKidPhoto(widget.childData.kid.id, path));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final kid = widget.childData.kid;
    return Container(
      decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(48.r)),
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(48.r),
                      topRight: Radius.circular(48.r),
                      bottomRight: Radius.circular(48.r),
                      bottomLeft: Radius.circular(8.r),
                    ),
                    child: SizedBox(
                      width: 160.w,
                      height: 160.w,
                      child: _pickedPhoto != null
                          ? Image.file(_pickedPhoto!, fit: BoxFit.cover)
                          : kid.photoUrl.isEmpty
                          ? Container(color: AppColors.surfaceSage, child: Icon(Icons.person, size: 64.w, color: palette.brandText))
                          : Image(
                              // Saved photos may be a local file path (no
                              // upload endpoint yet), not just a URL.
                              image: kidPhotoProvider(kid.photoUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.surfaceSage, child: Icon(Icons.person, size: 64.w, color: palette.brandText)),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 6.w,
                    right: 6.w,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.card, width: 3.w),
                      ),
                      child: Icon(Icons.camera_alt, size: 13.w, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            kid.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: AppFonts.jakarta, fontSize: 22.sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'child_profile_age_label'.tr(namedArgs: {'age': '$_ageYears'}),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: palette.textSecondary),
          ),
          SizedBox(height: 24.h),

          if (_allergies.isNotEmpty) ...[
            Text('child_profile_allergies_label'.tr(), style: _sectionLabelStyle(context)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final allergy in _allergies)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(color: AppColors.peachTint, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, size: 12.w, color: AppColors.allergyTagText),
                        SizedBox(width: 6.w),
                        Text(allergy, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.allergyTagText)),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
          ],

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: palette.sand, borderRadius: BorderRadius.circular(28.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('child_profile_emergency_contact_label'.tr(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: palette.amberText, letterSpacing: 1)),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    _iconBadge(context, Icons.person),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kid.emergencyContactName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                          Text('child_profile_emergency_relation'.tr(), style: TextStyle(fontSize: 11.sp, color: palette.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    _iconBadge(context, Icons.call),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kid.emergencyContactPhone, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                          Text('child_profile_primary_number'.tr(), style: TextStyle(fontSize: 11.sp, color: palette.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildQrSection(context, kid),
        ],
      ),
    );
  }

  Widget _buildQrSection(BuildContext context, Kid kid) {

  final palette = context.palette;
    final payload = kid.qrPayload;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: palette.cardMuted, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(16.r)),
            child: payload == null
                ? Icon(Icons.qr_code_2, size: 48.w, color: palette.divider)
                : QrImageView(data: payload, backgroundColor: Colors.white),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('child_profile_qr_title'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                SizedBox(height: 4.h),
                Text('child_profile_qr_subtitle'.tr(), style: TextStyle(fontSize: 12.sp, color: palette.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _sectionLabelStyle(BuildContext context) =>
      TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: context.palette.textSecondary, letterSpacing: 1);

  Widget _iconBadge(BuildContext context, IconData icon) {

  final palette = context.palette;
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(color: palette.chip, shape: BoxShape.circle),
      child: Icon(icon, size: 16.w, color: palette.textSecondary),
    );
  }
}
