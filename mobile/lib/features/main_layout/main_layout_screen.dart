import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_parents_system/features/billing/presentation/screens/billing_screen.dart';
import 'package:nursery_parents_system/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:nursery_parents_system/features/main_layout/presentation/cubit/main_layout_state.dart';
import 'package:nursery_parents_system/features/main_layout/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:nursery_parents_system/features/main_layout/presentation/widgets/global_app_bar.dart';
import 'package:nursery_parents_system/features/main_layout/presentation/widgets/main_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../history/presentation/screens/history_screen.dart';
import '../home/presentation/screens/home_screen.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  // رجعناهم 3 شاشات فقط
  final List<Widget> screens = const [
    HomeScreen(),
    HistoryScreen(),
    BillingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainLayoutCubit(),
      child: BlocBuilder<MainLayoutCubit, MainLayoutState>(
        builder: (context, state) {
          final cubit = context.read<MainLayoutCubit>();
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const GlobalAppBar(),
            drawer: const MainDrawer(),
            body: IndexedStack(
              index: cubit.currentIndex,
              children: screens,
            ),
            bottomNavigationBar: const CustomBottomNavBar(), // هترجع الـ 3 أزرار زي ما كانت
          );
        },
      ),
    );
  }
}