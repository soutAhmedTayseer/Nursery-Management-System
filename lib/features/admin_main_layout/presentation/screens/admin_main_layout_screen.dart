import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/overview_screen.dart';
import '../../../registration/presentation/screens/registration_screen.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../../sessions/presentation/screens/sessions_screen.dart';
import '../cubit/admin_main_layout_cubit.dart';
import '../cubit/admin_main_layout_state.dart';
import '../widgets/admin_app_bar.dart';
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
      const Center(child: Text('Finance Screen')),
      const Center(child: Text('Profiles Screen')),
      const Center(child: Text('Settings Screen')),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminMainLayoutCubit()),
        BlocProvider(create: (context) => SessionsCubit()..loadSessions()),
      ],
      child: BlocBuilder<AdminMainLayoutCubit, AdminMainLayoutState>(

        builder: (context, state) {
          final cubit = context.read<AdminMainLayoutCubit>();

          return Scaffold(
            backgroundColor: AppColors.background, // لون الأوف-وايت الأساسي
            body: SafeArea(
              child: Row(
                children: [
                  // 2. القائمة الجانبية (Sidebar)
                  const AdminSidebar(),
                  
                  // 3. الجزء الرئيسي (App Bar + Content)
                  Expanded(
                    child: Column(
                      children: [
                        // الـ Header اللي فيه البحث والـ QR
                        const AdminAppBar(),
                        
                        // محتوى الشاشات المتغير
                        Expanded(
                          child: IndexedStack(
                            index: cubit.currentIndex,
                            children: screens,
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
