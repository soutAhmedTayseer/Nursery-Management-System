import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/account/data/models/account.dart';
import 'package:nursery_management_system/features/account/data/repositories/account_repository.dart';
import 'package:nursery_management_system/features/admin_splash/presentation/cubit/splash_cubit.dart';
import 'package:nursery_management_system/features/admin_splash/presentation/cubit/splash_state.dart';
import 'package:nursery_management_system/features/auth/data/repositories/auth_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockTokenStorage extends Mock implements TokenStorage {}

const _account = Account(
  id: 'a1',
  fullName: 'ahmed tayseer',
  userName: 'superadmin',
  role: 'SuperAdmin',
);

void main() {
  late _MockAuthRepository auth;
  late _MockAccountRepository account;
  late _MockTokenStorage tokens;

  setUp(() {
    auth = _MockAuthRepository();
    account = _MockAccountRepository();
    tokens = _MockTokenStorage();
    when(tokens.clear).thenAnswer((_) async {});
  });

  SplashCubit build() => SplashCubit(auth, account, tokens);

  blocTest<SplashCubit, SplashState>(
    'navigates to the layout when a stored token still validates',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(account.fetchMe).thenAnswer((_) async => _account);
    },
    build: build,
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLayout>()],
  );

  blocTest<SplashCubit, SplashState>(
    'navigates to login when there is no session',
    setUp: () => when(() => auth.hasSession()).thenAnswer((_) async => false),
    build: build,
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLogin>()],
    verify: (_) => verifyNever(account.fetchMe),
  );

  blocTest<SplashCubit, SplashState>(
    'clears the token and goes to login when the probe is rejected',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(account.fetchMe).thenThrow(const ApiException(
        code: 'INVALID_REFRESH_TOKEN',
        message: 'revoked',
        statusCode: 401,
      ));
    },
    build: build,
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLogin>()],
    verify: (_) => verify(tokens.clear).called(1),
  );

  blocTest<SplashCubit, SplashState>(
    'keeps the token and opens the app when the probe fails on a network error',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(account.fetchMe).thenThrow(const ApiException(
        code: 'NETWORK_ERROR',
        message: 'offline',
        statusCode: null,
      ));
    },
    build: build,
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLayout>()],
    verify: (_) => verifyNever(tokens.clear),
  );

  blocTest<SplashCubit, SplashState>(
    'navigates to login when the session check throws',
    setUp: () =>
        when(() => auth.hasSession()).thenThrow(Exception('storage error')),
    build: build,
    act: (cubit) => cubit.checkSession(),
    expect: () => [isA<SplashNavigateToLogin>()],
  );
}
