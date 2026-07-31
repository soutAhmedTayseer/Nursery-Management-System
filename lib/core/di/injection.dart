import 'package:get_it/get_it.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../features/admin_login/presentation/cubit/admin_login_cubit.dart';
import '../../features/admin_splash/presentation/cubit/splash_cubit.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/sessions/data/repositories/fake_sessions_repository.dart';
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
  sl.registerLazySingleton<SessionsRepository>(
    () => FakeSessionsRepository(failureSwitch: sl<FakeFailureSwitch>()),
  );

  // --- Auth ---
  sl.registerLazySingleton<AuthRepository>(
    () => FakeAuthRepository(
      tokenStorage: sl<TokenStorage>(),
      failureSwitch: sl<FakeFailureSwitch>(),
    ),
  );

  // --- Cubits ---
  sl.registerFactory<SessionsCubit>(() => SessionsCubit(sl()));
  sl.registerFactory<AdminLoginCubit>(() => AdminLoginCubit(sl()));
  sl.registerFactory<SplashCubit>(() => SplashCubit(sl()));
}
