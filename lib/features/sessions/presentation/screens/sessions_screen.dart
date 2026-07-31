import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../cubit/sessions_cubit.dart';
import '../widgets/child_session_card.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.surfaceCream,
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32.h),
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
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPortrait ? 3 : 4,
                          mainAxisSpacing: 24.w,
                          crossAxisSpacing: 24.w,
                          childAspectRatio: isPortrait ? 0.72 : 0.85,
                        ),
                        itemCount: loaded.items.length,
                        itemBuilder: (context, index) =>
                            ChildSessionCard(entry: loaded.items[index]),
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<SessionsCubit, SessionsState>(
              builder: (context, state) {
                if (state is SessionsLoaded) {
                  return _buildDynamicPaginationFooter(context, state);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('sessions_title'.tr(), style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text('sessions_subtitle'.tr(), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Row(
          children: [
            _buildSummarySmallCard('sessions_current_count_label'.tr(), 'sessions_current_count_value'.tr(), Icons.face_rounded),
            SizedBox(width: 16.w),
            _buildSummarySmallCard('sessions_block_label'.tr(), '08:00 - 13:00', Icons.schedule),
          ],
        )
      ],
    );
  }

  Widget _buildSummarySmallCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        children: [
          CircleAvatar(radius: 18.r, backgroundColor: AppColors.surfaceSage, child: Icon(icon, color: AppColors.accentGreen, size: 18.w)),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDynamicPaginationFooter(BuildContext context, SessionsLoaded state) {
    final cubit = context.read<SessionsCubit>();

    int startItem = (state.currentPage - 1) * cubit.pageSize + 1;
    int endItem = startItem + state.items.length - 1;
    if (state.totalCount == 0) {
      startItem = 0;
      endItem = 0;
    }

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'sessions_pagination_showing'.tr(namedArgs: {
              'start': '$startItem',
              'end': '$endItem',
              'total': '${state.totalCount}',
            }),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600)
          ),
          Row(
            children: [
              _buildPageArrowBtn(
                Icons.chevron_left,
                isActive: state.currentPage > 1,
                onTap: () {
                  if (state.currentPage > 1) cubit.changePage(state.currentPage - 1);
                }
              ),
              SizedBox(width: 8.w),
              ...List.generate(state.totalPages, (index) {
                int pageNum = index + 1;
                return _buildPageNumber(
                  pageNum.toString(),
                  isActive: pageNum == state.currentPage,
                  onTap: () => cubit.changePage(pageNum),
                );
              }),
              SizedBox(width: 8.w),
              _buildPageArrowBtn(
                Icons.chevron_right,
                isActive: state.currentPage < state.totalPages,
                onTap: () {
                  if (state.currentPage < state.totalPages) cubit.changePage(state.currentPage + 1);
                }
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPageNumber(String n, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w, height: 36.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(color: isActive ? AppColors.accentGreen : Colors.grey.shade200, shape: BoxShape.circle),
        child: Center(child: Text(n, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildPageArrowBtn(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w, height: 36.w,
        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
        child: Icon(icon, size: 20.w, color: isActive ? Colors.black87 : Colors.grey.shade400),
      ),
    );
  }
}
