import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/overview_screen.dart';
import '../../../finance/presentation/screens/finance_screen.dart';
import '../../../registration/presentation/screens/registration_screen.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../../sessions/presentation/screens/sessions_screen.dart';
import '../../../subscriptions/presentation/screens/subscribed_children_screen.dart';
import '../cubit/admin_main_layout_cubit.dart';
import '../cubit/admin_main_layout_state.dart';
import '../widgets/admin_sidebar.dart';

class AdminMainLayoutScreen extends StatelessWidget {
  const AdminMainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Placeholder Screens (هنستبدلها بالشاشات الحقيقية لما نبنيها)
    final List<Widget> screens = [
      const OverviewScreen(),
      const RegistrationScreen(),
      const SessionsScreen(),
      const SubscribedChildrenScreen(),
      const FinanceScreen(),
      Center(child: Text('layout_profiles_screen'.tr())),
      Center(child: Text('layout_settings_screen'.tr())),
    ];


    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminMainLayoutCubit()),
        BlocProvider(create: (_) => sl<SessionsCubit>()..loadSessions()),
      ],
      child: BlocBuilder<AdminMainLayoutCubit, AdminMainLayoutState>(
        builder: (context, state) {
          final cubit = context.read<AdminMainLayoutCubit>();
          final isCompact = context.isCompact;

          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: isCompact ? Drawer(child: SafeArea(child: AdminSidebar(forceFull: true))) : null,
            body: SafeArea(
              child: Row(
                children: [
                  // 2. Sidebar
                  if (!isCompact) const AdminSidebar(),

                  // 3. Main content
                  Expanded(
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: cubit.currentIndex,
                          children: screens,
                        ),
                        if (isCompact)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Builder(
                              builder: (context) => Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
