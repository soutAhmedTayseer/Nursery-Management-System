import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../child_profile/presentation/screens/child_profile_details_screen.dart';
import '../../data/repositories/sessions_repository.dart';
import '../cubit/sessions_cubit.dart';
import '../widgets/child_session_card.dart';
import '../widgets/qr_scan_dialog.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  Future<void> _scanQr(BuildContext context) async {
    final payload = await QrScanDialog.show(context);
    if (payload == null || !context.mounted) return;
    final kidName = await context.read<SessionsCubit>().handleQrScan(payload);
    if (!context.mounted) return;
    if (kidName == null) {
      AppSnackbar.showError(context, 'session_scan_qr_invalid'.tr());
    } else {
      AppSnackbar.showSuccess(context, 'session_scan_qr_success'.tr(namedArgs: {'name': kidName}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'appbar_search_hint'.tr(),
                    onChanged: (query) => context.read<SessionsCubit>().search(query),
                  ),
                ),
                SizedBox(width: 16.w),
                _ScanQrButton(onTap: () => _scanQr(context)),
              ],
            ),
            SizedBox(height: 16.h),
            BlocBuilder<SessionsCubit, SessionsState>(
              builder: (context, state) {
                if (state is! SessionsLoaded) return const SizedBox();
                final cubit = context.read<SessionsCubit>();
                // The counts double as the filter: tapping one narrows the
                // roster to those children, tapping it again clears it.
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 8.h,
                  children: [
                    _CountPill(
                      icon: Icons.login,
                      color: AppColors.accentGreen,
                      label: 'session_count_checked_in'.tr(namedArgs: {'count': '${state.checkedInCount}'}),
                      isSelected: state.filter == AttendanceFilter.checkedIn,
                      onTap: () => cubit.setFilter(
                        state.filter == AttendanceFilter.checkedIn ? AttendanceFilter.all : AttendanceFilter.checkedIn,
                      ),
                    ),
                    _CountPill(
                      icon: Icons.logout,
                      color: Colors.grey.shade600,
                      label: 'session_count_checked_out'.tr(namedArgs: {'count': '${state.checkedOutCount}'}),
                      isSelected: state.filter == AttendanceFilter.checkedOut,
                      onTap: () => cubit.setFilter(
                        state.filter == AttendanceFilter.checkedOut ? AttendanceFilter.all : AttendanceFilter.checkedOut,
                      ),
                    ),
                    if (state.filter != AttendanceFilter.all)
                      _CountPill(
                        icon: Icons.close,
                        color: AppColors.textSecondary,
                        label: 'session_filter_clear'.tr(),
                        onTap: () => cubit.setFilter(AttendanceFilter.all),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  final isLoaded = state is SessionsLoaded;
                  return AsyncStateView(
                    isLoading: state is SessionsLoading || state is SessionsInitial,
                    error: state is SessionsError ? state.exception : null,
                    isEmpty: isLoaded && state.items.isEmpty,
                    onRetry: () => context.read<SessionsCubit>().loadSessions(),
                    emptyMessage: 'sessions_none_found'.tr(),
                    builder: (context) {
                      final loaded = state as SessionsLoaded;
                      final cubit = context.read<SessionsCubit>();
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragEnd: (details) {
                          final velocity = details.primaryVelocity ?? 0;
                          if (velocity.abs() < 200) return;
                          if (velocity < 0 && loaded.currentPage < loaded.totalPages) {
                            cubit.changePage(loaded.currentPage + 1);
                          } else if (velocity > 0 && loaded.currentPage > 1) {
                            cubit.changePage(loaded.currentPage - 1);
                          }
                        },
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: const ResponsiveValue<int>(compact: 2, medium: 3, expanded: 4).resolve(context),
                            mainAxisSpacing: 24.w,
                            crossAxisSpacing: 24.w,
                            childAspectRatio: MediaQuery.orientationOf(context) == Orientation.portrait
                                ? 1.05
                                : const ResponsiveValue<double>(compact: 0.82, medium: 0.78, expanded: 0.85).resolve(context),
                          ),
                          itemCount: loaded.items.length,
                          itemBuilder: (context, index) => ChildSessionCard(
                            entry: loaded.items[index],
                            // The pushed route is built by the root
                            // Navigator, which sits ABOVE the layout's
                            // BlocProvider — without re-providing it here,
                            // the details screen can't reach SessionsCubit
                            // (that's what silently broke saving a picked
                            // child photo back to the roster).
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: cubit,
                                  child: ChildProfileDetailsScreen(childData: loaded.items[index]),
                                ),
                              ),
                            ),
                            onClockIn: () => cubit.clockIn(loaded.items[index].kid.id),
                            onClockOut: () => cubit.clockOut(loaded.items[index].kid.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<SessionsCubit, SessionsState>(
              builder: (context, state) {
                final cubit = context.read<SessionsCubit>();
                if (state is SessionsLoaded) {
                  return PaginationFooter(
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    totalCount: state.totalCount,
                    pageSize: cubit.pageSize,
                    itemCount: state.items.length,
                    onPageChanged: cubit.changePage,
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amberTint,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 18.w, color: AppColors.brownDark),
              SizedBox(width: 8.w),
              Text('session_scan_qr_button'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.brownDark)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A roster count that doubles as a filter toggle. Selected state is carried
/// by a tinted fill and border so it reads as "active filter", not just hover.
class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.icon,
    required this.color,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.14) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 14.w, color: color),
            ),
            SizedBox(width: 10.w),
            Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
