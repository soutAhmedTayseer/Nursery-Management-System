import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sessions/data/models/kid_session.dart';
import '../widgets/financial_dues_tab.dart';

/// Standalone full-screen wrapper around [FinancialDuesTab]. Most
/// navigation now goes through ChildProfileDetailsScreen's Financial Dues
/// tab instead — this stays available for any flow that wants to jump
/// straight to plan management.
class ManageSubscriptionScreen extends StatelessWidget {
  final KidSession childData;

  const ManageSubscriptionScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.accentGreen, size: 20.w),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.w),
        physics: const BouncingScrollPhysics(),
        child: FinancialDuesTab(childData: childData),
      ),
    );
  }
}
