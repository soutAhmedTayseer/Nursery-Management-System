import 'package:get_it/get_it.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../features/admin_login/presentation/cubit/admin_login_cubit.dart';
import '../../features/admin_splash/presentation/cubit/splash_cubit.dart';
import '../../features/auth/data/repositories/api_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/finance/data/repositories/api_finance_repository.dart';
import '../../features/finance/data/repositories/fake_finance_repository.dart';
import '../../features/finance/data/repositories/finance_repository.dart';
import '../../features/kids/data/repositories/api_kids_repository.dart';
import '../../features/kids/data/repositories/fake_kids_repository.dart';
import '../../features/kids/data/repositories/kids_repository.dart';
import '../../features/sessions/data/repositories/api_sessions_repository.dart';
import '../../features/sessions/data/repositories/fake_sessions_repository.dart';
import '../../features/sessions/data/repositories/sessions_repository.dart';
import '../../features/sessions/presentation/cubit/sessions_cubit.dart';
import '../../features/settings/data/repositories/api_settings_repository.dart';
import '../../features/settings/data/repositories/fake_settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/subscriptions/data/repositories/api_plans_repository.dart';
import '../../features/subscriptions/data/repositories/fake_plans_repository.dart';
import '../../features/subscriptions/data/repositories/plans_repository.dart';
import '../testing/fake_failure_switch.dart';

final GetIt sl = GetIt.instance;

/// Forces every repository back onto its fake implementation.
///
/// Integration lands one feature at a time: a phase flips its own registration
/// below to the API implementation while the rest keep running on fakes, so
/// each phase ships independently. `--dart-define=USE_FAKES=true` overrides the
/// lot and runs the app fully offline — which is also how widget tests boot it.
const useFakes = bool.fromEnvironment('USE_FAKES');

/// Wires the whole app.
///
/// A registration still reading `Fake<X>Repository()` unconditionally has not
/// been integrated yet; one reading the [useFakes] ternary has.
Future<void> setupLocator({required String baseUrl}) async {
  if (sl.isRegistered<ApiClient>()) return;

  // --- Infrastructure ---
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: baseUrl, tokenStorage: sl<TokenStorage>()),
  );
  sl.registerLazySingleton<FakeFailureSwitch>(() => FakeFailureSwitch());

  // --- Sessions (integrated: Phase 3) ---
  sl.registerLazySingleton<SessionsRepository>(
    () => useFakes
        ? FakeSessionsRepository(failureSwitch: sl<FakeFailureSwitch>())
        : ApiSessionsRepository(sl<ApiClient>()),
  );

  // --- Kids (integrated: Phase 2) ---
  sl.registerLazySingleton<KidsRepository>(
    () => useFakes
        ? FakeKidsRepository(failureSwitch: sl<FakeFailureSwitch>())
        : ApiKidsRepository(sl<ApiClient>()),
  );

  // --- Auth (integrated: Phase 1) ---
  sl.registerLazySingleton<AuthRepository>(
    () => useFakes
        ? FakeAuthRepository(
            tokenStorage: sl<TokenStorage>(),
            failureSwitch: sl<FakeFailureSwitch>(),
          )
        : ApiAuthRepository(
            client: sl<ApiClient>(),
            tokenStorage: sl<TokenStorage>(),
          ),
  );

  // --- Plans & subscriptions (integrated: Phase 4) ---
  sl.registerLazySingleton<PlansRepository>(
    () => useFakes
        ? FakePlansRepository(failureSwitch: sl<FakeFailureSwitch>())
        : ApiPlansRepository(sl<ApiClient>()),
  );

  // --- Finance (integrated: Phase 5) ---
  sl.registerLazySingleton<FinanceRepository>(
    () => useFakes
        ? FakeFinanceRepository(failureSwitch: sl<FakeFailureSwitch>())
        : ApiFinanceRepository(sl<ApiClient>()),
  );

  // --- Dashboard & settings (integrated: Phase 6) ---
  sl.registerLazySingleton<DashboardRepository>(
    () => useFakes
        ? FakeDashboardRepository(
            sessionsRepository: sl<SessionsRepository>(),
            failureSwitch: sl<FakeFailureSwitch>(),
          )
        : ApiDashboardRepository(sl<ApiClient>()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => useFakes
        ? FakeSettingsRepository(failureSwitch: sl<FakeFailureSwitch>())
        : ApiSettingsRepository(sl<ApiClient>()),
  );

  // --- Cubits ---
  sl.registerFactory<SessionsCubit>(() => SessionsCubit(sl()));
  sl.registerFactory<AdminLoginCubit>(() => AdminLoginCubit(sl()));
  sl.registerFactory<SplashCubit>(() => SplashCubit(sl()));
}
