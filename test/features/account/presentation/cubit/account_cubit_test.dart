import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/account/data/models/account.dart';
import 'package:nursery_management_system/features/account/data/repositories/account_repository.dart';
import 'package:nursery_management_system/features/account/presentation/cubit/account_cubit.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

const _account = Account(
  id: 'a1',
  fullName: 'ahmed tayseer',
  userName: 'superadmin',
  role: 'SuperAdmin',
  phoneNumber: '01119450425',
);

void main() {
  late _MockAccountRepository repository;

  setUp(() => repository = _MockAccountRepository());

  test('starts in AccountInitial', () {
    expect(AccountCubit(repository).state, isA<AccountInitial>());
  });

  blocTest<AccountCubit, AccountState>(
    'load emits Loading then Loaded',
    setUp: () => when(repository.fetchMe).thenAnswer((_) async => _account),
    build: () => AccountCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AccountLoading>(),
      isA<AccountLoaded>().having((s) => s.account.userName, 'userName', 'superadmin'),
    ],
  );

  blocTest<AccountCubit, AccountState>(
    'load emits Loading then Error carrying the ApiException',
    setUp: () => when(repository.fetchMe).thenThrow(
      const ApiException(code: 'UNAUTHORIZED', message: 'nope', statusCode: 401),
    ),
    build: () => AccountCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AccountLoading>(),
      isA<AccountError>().having((s) => s.exception.code, 'code', 'UNAUTHORIZED'),
    ],
  );

  blocTest<AccountCubit, AccountState>(
    'save emits Loaded with the updated account',
    setUp: () => when(() => repository.updateMe(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenAnswer((_) async => _account.copyWith(fullName: 'New Name')),
    build: () => AccountCubit(repository),
    act: (cubit) => cubit.save(fullName: 'New Name', phoneNumber: '01119450425'),
    expect: () => [
      isA<AccountLoaded>().having((s) => s.account.fullName, 'fullName', 'New Name'),
    ],
  );

  blocTest<AccountCubit, AccountState>(
    'save emits Error when the repository throws',
    setUp: () => when(() => repository.updateMe(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenThrow(
      const ApiException(code: 'VALIDATION', message: 'bad', statusCode: 400),
    ),
    build: () => AccountCubit(repository),
    act: (cubit) => cubit.save(fullName: '', phoneNumber: ''),
    expect: () => [
      isA<AccountError>().having((s) => s.exception.code, 'code', 'VALIDATION'),
    ],
  );

  blocTest<AccountCubit, AccountState>(
    'changePassword delegates to the repository and emits nothing',
    setUp: () => when(() => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async {}),
    build: () => AccountCubit(repository),
    act: (cubit) =>
        cubit.changePassword(currentPassword: 'old', newPassword: 'newpass'),
    expect: () => const <AccountState>[],
    verify: (_) => verify(() => repository.changePassword(
          currentPassword: 'old',
          newPassword: 'newpass',
        )).called(1),
  );
}
