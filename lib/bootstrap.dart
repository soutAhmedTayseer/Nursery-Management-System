import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nursery_shared/nursery_shared.dart';
import 'package:window_manager/window_manager.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/finance/presentation/cubit/finance_cubit.dart';
import 'features/subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import 'features/subscriptions/presentation/cubit/plans_cubit.dart';

const _minWindowSize = Size(1280, 800);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupLocator(baseUrl: AppEnv.apiBaseUrl);

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(_minWindowSize);
    final size = await windowManager.getSize();
    if (size.width < _minWindowSize.width || size.height < _minWindowSize.height) {
      await windowManager.setSize(_minWindowSize);
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width;
    return ScreenUtilInit(
      // Swap design axes in portrait so `.sp`/`.w`/`.h` scale off the same
      // physical dimension as landscape — otherwise rotating a tablet shrinks
      // every font because the short edge suddenly maps to the 1440 axis.
      designSize: isPortrait ? const Size(900, 1440) : const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => PlansCubit()),
            BlocProvider(create: (_) => PlanAssignmentsCubit()),
            BlocProvider(create: (_) => FinanceCubit()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'app_title'.tr(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light(),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.adminSplash,
          ),
        );
      },
    );
  }
}
