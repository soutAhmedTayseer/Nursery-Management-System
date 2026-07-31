import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/admin_login/presentation/cubit/admin_login_cubit.dart';
import 'package:nursery_management_system/features/auth/data/repositories/auth_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  test('starts in AdminLoginInitial', () {
    expect(AdminLoginCubit(repository).state, isA<AdminLoginInitial>());
  });

  blocTest<AdminLoginCubit, AdminLoginState>(
    'emits Loading then Success on a successful login',
    setUp: () => when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {}),
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.login('admin@wildwood.com', 'secret'),
    expect: () => [isA<AdminLoginLoading>(), isA<AdminLoginSuccess>()],
  );

  blocTest<AdminLoginCubit, AdminLoginState>(
    'emits Loading then Error carrying the ApiException on failure',
    setUp: () => when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const ApiException(
      code: 'INVALID_CREDENTIALS',
      message: 'boom',
      statusCode: 401,
    )),
    build: () => AdminLoginCubit(repository),
    act: (cubit) => cubit.login('admin@wildwood.com', 'wrong'),
    expect: () => [
      isA<AdminLoginLoading>(),
      isA<AdminLoginError>().having((s) => s.exception.code, 'code', 'INVALID_CREDENTIALS'),
    ],
  );
}
