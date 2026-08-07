import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../../sessions/presentation/widgets/qr_scan_dialog.dart';
import '../../../../core/theme/app_palette.dart';

class AdminAppBar extends StatefulWidget {
  const AdminAppBar({super.key});

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();
}

class _AdminAppBarState extends State<AdminAppBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Same clock-in/out scan the Sessions screen offers, reachable from any
  /// tab — this button used to be inert.
  Future<void> _scanQr() async {
    final payload = await QrScanDialog.show(context);
    if (payload == null || !mounted) return;
    final kidName = await context.read<SessionsCubit>().handleQrScan(payload);
    if (!mounted) return;
    if (kidName == null) {
      AppSnackbar.showError(context, 'session_scan_qr_invalid'.tr());
    } else {
      AppSnackbar.showSuccess(context, 'session_scan_qr_success'.tr(namedArgs: {'name': kidName}));
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<SessionsCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      color: AppColors.background, // نفس لون خلفية الـ Dashboard الرئيسي
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (context.isCompact) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            SizedBox(width: 8.w),
          ],
          // Search Bar
          Expanded(
            flex: 2, // عشان ياخد مساحة أكبر لكن ميفردش للأخر
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'appbar_search_hint'.tr(),
                  hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: palette.textTertiary, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          
          Expanded(flex: 1, child: SizedBox()), // مسافة مرنة في النص
          
          // Scan QR Button
          ElevatedButton.icon(
            onPressed: _scanQr,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberTint, // لون برتقالي فاتح
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              elevation: 0,
            ),
            icon: Icon(Icons.qr_code_scanner, color: AppColors.amberLabel, size: 20.w),
            label: Text(
              'appbar_scan_qr'.tr(),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.amberLabel),
            ),
          ),
        ],
      ),
    );
  }
}
