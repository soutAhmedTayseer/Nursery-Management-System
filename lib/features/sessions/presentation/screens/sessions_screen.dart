import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../subscriptions/presentation/screens/manage_subscription_screen.dart';
import '../cubit/sessions_cubit.dart';
import '../widgets/child_session_card.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCream,
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              hint: 'appbar_search_hint'.tr(),
              onChanged: (query) => context.read<SessionsCubit>().search(query),
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManageSubscriptionScreen(childData: loaded.items[index]),
                              ),
                            ),
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
