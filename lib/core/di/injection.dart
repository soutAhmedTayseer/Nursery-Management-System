import 'package:get_it/get_it.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../features/account/data/repositories/account_repository.dart';
import '../../features/account/data/repositories/api_account_repository.dart';
import '../../features/account/presentation/cubit/account_cubit.dart';
import '../../features/admin_login/presentation/cubit/admin_login_cubit.dart';
import '../../features/admin_splash/presentation/cubit/splash_cubit.dart';
import '../../features/auth/data/repositories/api_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/children/data/repositories/api_children_repository.dart';
import '../../features/children/data/repositories/children_repository.dart';
import '../../features/sessions/data/repositories/api_sessions_repository.dart';
import '../../features/sessions/data/repositories/sessions_repository.dart';
import '../../features/sessions/presentation/cubit/sessions_cubit.dart';
import '../testing/fake_failure_switch.dart';

final GetIt sl = GetIt.instance;

/// Wires the whole app.
///
/// Integration day: change each `Fake<X>Repository()` below to
/// `Api<X>Repository(sl<ApiClient>())`. No screen, cubit or test changes.
Future<void> setupLocator({required String baseUrl}) async {
  if (sl.isRegistered<ApiClient>()) return;

  // --- Infrastructure ---
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: baseUrl, tokenStorage: sl<TokenStorage>()),
  );
  sl.registerLazySingleton<FakeFailureSwitch>(() => FakeFailureSwitch());

  // --- Repositories (swap these at integration) ---
  // Sessions roster now reads the live GET /api/children list. Check-in/out
  // and the QR clock flow stay stubbed until Phase 2 (/api/attendance/*).
  sl.registerLazySingleton<SessionsRepository>(
    () => ApiSessionsRepository(sl<ChildrenRepository>()),
  );

  // --- Auth + account (live) ---
  sl.registerLazySingleton<AuthRepository>(
    () => ApiAuthRepository(
      client: sl<ApiClient>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => ApiAccountRepository(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ChildrenRepository>(
    () => ApiChildrenRepository(sl<ApiClient>()),
  );

  // --- Cubits ---
  sl.registerFactory<SessionsCubit>(() => SessionsCubit(sl()));
  sl.registerFactory<AdminLoginCubit>(() => AdminLoginCubit(sl()));
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(sl(), sl(), sl<TokenStorage>()),
  );
  sl.registerFactory<AccountCubit>(() => AccountCubit(sl()));
}
