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
import 'core/testing/demo_seed.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/cubit/schedule_cubit.dart';
import 'features/finance/presentation/cubit/audit_log_cubit.dart';
import 'features/finance/presentation/cubit/finance_cubit.dart';
import 'features/settings/data/app_settings.dart';
import 'features/settings/presentation/cubit/app_settings_cubit.dart';
import 'features/subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import 'features/subscriptions/presentation/cubit/plan_history_cubit.dart';
import 'features/subscriptions/presentation/cubit/plans_cubit.dart';

const _minWindowSize = Size(1280, 800);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupLocator(baseUrl: AppEnv.apiBaseUrl);

  // No backend yet: fabricate the demo roster's attendance history and
  // restore any photos the admin picked in an earlier run, so the app opens
  // with a coherent, self-consistent dataset.
  seedDemoAttendance();
  await restoreDemoPhotos();

  // Loaded before the first frame so the app opens straight into the
  // admin's chosen theme instead of flashing the default one.
  final settings = AppSettingsCubit();
  await settings.load();

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(_minWindowSize);
    final size = await windowManager.getSize();
    if (size.width < _minWindowSize.width ||
        size.height < _minWindowSize.height) {
      await windowManager.setSize(_minWindowSize);
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(settings: settings),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.settings});

  /// Pre-loaded so the first frame already has the admin's theme. Null in
  /// tests, where a fresh cubit with defaults is fine.
  final AppSettingsCubit? settings;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width;
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
            BlocProvider(create: (_) => PlansCubit(sl())..load()),
            BlocProvider(create: (_) => PlanAssignmentsCubit(sl())),
            BlocProvider(create: (_) => PlanHistoryCubit(sl())),
            BlocProvider(create: (_) => FinanceCubit()),
            BlocProvider(create: (_) => AuditLogCubit()),
            BlocProvider(create: (_) => ScheduleCubit()),
            BlocProvider(create: (_) => settings ?? AppSettingsCubit()),
          ],
          child: BlocBuilder<AppSettingsCubit, AppSettings>(
            builder: (context, appSettings) {
              final language = context.locale.languageCode;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'app_title'.tr(),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.light(languageCode: language),
                darkTheme: AppTheme.dark(languageCode: language),
                themeMode: appSettings.themeMode,
                // The admin's text-size preference multiplies whatever the
                // OS already applies, so accessibility settings still count.
                builder: (context, child) => MediaQuery.withClampedTextScaling(
                  minScaleFactor: appSettings.textScale,
                  maxScaleFactor: appSettings.textScale,
                  child: child!,
                ),
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: AppRoutes.adminSplash,
              );
            },
          ),
        );
      },
    );
  }
}
