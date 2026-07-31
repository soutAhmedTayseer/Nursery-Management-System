import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/admin_splash/presentation/cubit/splash_cubit.dart';
import 'package:nursery_management_system/features/admin_splash/presentation/cubit/splash_state.dart';
import 'package:nursery_management_system/features/auth/data/repositories/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  blocTest<SplashCubit, SplashState>(
    'navigates to the layout when a session already exists',
    setUp: () => when(() => repository.hasSession()).thenAnswer((_) async => true),
    build: () => SplashCubit(repository),
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLayout>()],
  );

  blocTest<SplashCubit, SplashState>(
    'navigates to login when there is no session',
    setUp: () => when(() => repository.hasSession()).thenAnswer((_) async => false),
    build: () => SplashCubit(repository),
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLogin>()],
  );

  blocTest<SplashCubit, SplashState>(
    'navigates to login when the session check throws',
    setUp: () => when(() => repository.hasSession()).thenThrow(Exception('storage error')),
    build: () => SplashCubit(repository),
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLogin>()],
  );
}
