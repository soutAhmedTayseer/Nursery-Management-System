import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../../../subscriptions/presentation/widgets/financial_dues_tab.dart';
import '../cubit/attendance_cubit.dart';
import '../utils/child_profile_export.dart';
import '../widgets/attendance_log_tab.dart';
import '../widgets/child_profile_card.dart';

class ChildProfileDetailsScreen extends StatefulWidget {
  const ChildProfileDetailsScreen({super.key, required this.childData});

  final KidSession childData;

  @override
  State<ChildProfileDetailsScreen> createState() => _ChildProfileDetailsScreenState();
}

class _ChildProfileDetailsScreenState extends State<ChildProfileDetailsScreen> {
  int _tabIndex = 0;
  late String _currentPlanTitle = widget.childData.planLabel;
  String _currentPlanPrice = '—';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceCubit(widget.childData.kid.id),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.surfaceCream,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 32.h),
                  _buildTabSwitcher(),
                  SizedBox(height: 24.h),
                  IndexedStack(
                    index: _tabIndex,
                    alignment: Alignment.topCenter,
                    children: [
                      _buildAttendancePane(context),
                      FinancialDuesTab(
                        childData: widget.childData,
                        showChildIdentity: false,
                        onPlanChanged: (title, price) => setState(() {
                          _currentPlanTitle = title;
                          _currentPlanPrice = price;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.accentGreen, size: 20.w),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            widget.childData.kid.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: AppFonts.jakarta, fontSize: 30.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.75),
          ),
        ),
        SizedBox(width: 16.w),
        InkWell(
          onTap: () => exportChildProfileCsv(
            context: context,
            childData: widget.childData,
            currentPlanTitle: _currentPlanTitle,
            currentPlanPrice: _currentPlanPrice,
            attendance: context.read<AttendanceCubit>().state,
          ),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(colors: [AppColors.darkGreen, AppColors.brandGradientLight]),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ios_share_rounded, size: 16.w, color: Colors.white),
                SizedBox(width: 8.w),
                Text('child_profile_export'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: AppColors.surfaceSand.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabBtn(0, 'child_profile_tab_attendance'.tr()),
          _tabBtn(1, 'child_profile_tab_financial'.tr()),
        ],
      ),
    );
  }

  /// Attendance Log tab pairs with the child's profile card (matches the
  /// Figma child-profile screen). The Financial Dues tab is its own
  /// standalone layout (matches the Figma "Manage Subscriptions" screen,
  /// node 4:1111) with no side profile card — the child is already
  /// identified by the page header, so repeating photo/name there is
  /// redundant.
  Widget _buildAttendancePane(BuildContext context) {
    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildProfileCard(childData: widget.childData),
          SizedBox(height: 24.h),
          AttendanceLogTab(kid: widget.childData.kid),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: ChildProfileCard(childData: widget.childData)),
        SizedBox(width: 32.w),
        Expanded(flex: 8, child: AttendanceLogTab(kid: widget.childData.kid)),
      ],
    );
  }

  Widget _tabBtn(int index, String label) {
    final isActive = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
