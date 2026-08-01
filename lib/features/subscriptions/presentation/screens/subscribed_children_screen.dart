import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/responsive_value.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../widgets/child_subscription_card.dart';
import 'manage_subscription_screen.dart';

class SubscribedChildrenScreen extends StatelessWidget {
  const SubscribedChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCream,
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
                'subscribed_children_title'.tr(),
                style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)
            ),
            Text(
                'subscribed_children_subtitle'.tr(),
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)
            ),
            SizedBox(height: 32.h),

            // Children Grid
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  return AsyncStateView(
                    isLoading: state is SessionsLoading || state is SessionsInitial,
                    error: state is SessionsError ? state.exception : null,
                    isEmpty: state is SessionsLoaded && state.items.isEmpty,
                    onRetry: () => context.read<SessionsCubit>().loadSessions(),
                    emptyMessage: 'sessions_none_found'.tr(),
                    builder: (context) {
                      final loaded = state as SessionsLoaded;
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: const ResponsiveValue<int>(compact: 2, medium: 3, expanded: 4).resolve(context),
                          mainAxisSpacing: 24.w,
                          crossAxisSpacing: 24.w,
                          childAspectRatio: const ResponsiveValue<double>(compact: 0.78, medium: 0.75, expanded: 0.85).resolve(context),
                        ),
                        itemCount: loaded.items.length,
                        itemBuilder: (context, index) {
                          final child = loaded.items[index];
                          return ChildSubscriptionCard(
                            child: child,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageSubscriptionScreen(childData: child),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}