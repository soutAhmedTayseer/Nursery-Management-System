import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/children/data/repositories/children_repository.dart';
import 'package:nursery_management_system/features/children/presentation/cubit/child_profile_cubit.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockChildrenRepository extends Mock implements ChildrenRepository {}

Child _child({
  String scanCode = 'SCAN-1',
  ChildStatus status = ChildStatus.active,
  String photoUrl = '',
}) =>
    Child(
      id: 'c1',
      fullName: 'Lina',
      dateOfBirth: DateTime(2022, 1, 15),
      enrollmentDate: DateTime(2026, 8, 1),
      nationality: 'Egyptian',
      religion: '',
      homeAddress: 'Cairo',
      allergies: null,
      photoUrl: photoUrl,
      scanCode: scanCode,
      isActive: true,
      approvalStatus: 'Approved',
      status: status,
      createdAt: DateTime(2026, 8, 1),
      createdBy: null,
      approvedAt: null,
      approvedBy: null,
      mother: null,
      father: null,
      agreement: null,
      emergencyContacts: const [],
      currentPlan: null,
    );

final _input = ChildInput(
  fullName: 'Lina',
  dateOfBirth: DateTime(2022, 1, 15),
  enrollmentDate: DateTime(2026, 8, 1),
  nationality: 'Egyptian',
  religion: '',
  homeAddress: 'Cairo',
  allergies: null,
  mother: const ParentContact(
    fullName: 'M', phone: '1', email: 'm@e.com', occupation: '',
    jobTitle: '', companyName: '', workPhone: '', address: '',
  ),
  father: const ParentContact(
    fullName: '', phone: '', email: '', occupation: '',
    jobTitle: '', companyName: '', workPhone: '', address: '',
  ),
  agreement: ChildAgreement(
    mediaPermission: true,
    parentSignature: 'M',
    signedDate: DateTime(2026, 8, 1),
    acceptedTerms: true,
  ),
);

void main() {
  late _MockChildrenRepository repo;

  setUp(() {
    repo = _MockChildrenRepository();
    registerFallbackValue(ChildStatus.active);
    registerFallbackValue(
      const NewEmergencyContact(name: '', relationship: '', phone: ''),
    );
    registerFallbackValue(_input);
  });

  test('starts in ChildProfileInitial', () {
    expect(ChildProfileCubit(repo, 'c1').state, isA<ChildProfileInitial>());
  });

  blocTest<ChildProfileCubit, ChildProfileState>(
    'load emits Loading then Loaded',
    setUp: () =>
        when(() => repo.fetchChild('c1')).thenAnswer((_) async => _child()),
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) => c.load(),
    expect: () => [
      isA<ChildProfileLoading>(),
      isA<ChildProfileLoaded>()
          .having((s) => s.child.scanCode, 'scanCode', 'SCAN-1'),
    ],
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'load emits Error carrying the ApiException',
    setUp: () => when(() => repo.fetchChild('c1')).thenThrow(
      const ApiException(code: 'NOT_FOUND', message: 'x', statusCode: 404),
    ),
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) => c.load(),
    expect: () => [
      isA<ChildProfileLoading>(),
      isA<ChildProfileError>().having((s) => s.exception.code, 'code', 'NOT_FOUND'),
    ],
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'regenerateScanCode emits mutating then the fresh child',
    setUp: () {
      when(() => repo.fetchChild('c1')).thenAnswer((_) async => _child());
      when(() => repo.regenerateScanCode('c1'))
          .thenAnswer((_) async => _child(scanCode: 'SCAN-2'));
    },
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) async {
      await c.load();
      await c.regenerateScanCode();
    },
    skip: 2,
    expect: () => [
      isA<ChildProfileLoaded>().having((s) => s.mutating, 'mutating', true),
      isA<ChildProfileLoaded>()
          .having((s) => s.child.scanCode, 'scanCode', 'SCAN-2')
          .having((s) => s.mutating, 'mutating', false),
    ],
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'updateChild forwards the input and emits the refreshed child',
    setUp: () {
      when(() => repo.fetchChild('c1')).thenAnswer((_) async => _child());
      when(() => repo.updateChild('c1', any()))
          .thenAnswer((_) async => _child(photoUrl: 'kept'));
    },
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) async {
      await c.load();
      await c.updateChild(_input);
    },
    skip: 3,
    expect: () => [
      isA<ChildProfileLoaded>().having((s) => s.mutating, 'mutating', false),
    ],
    verify: (_) => verify(() => repo.updateChild('c1', _input)).called(1),
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'setStatus forwards the enum to the repository',
    setUp: () {
      when(() => repo.fetchChild('c1')).thenAnswer((_) async => _child());
      when(() => repo.setStatus('c1', ChildStatus.inactive))
          .thenAnswer((_) async => _child(status: ChildStatus.inactive));
    },
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) async {
      await c.load();
      await c.setStatus(ChildStatus.inactive);
    },
    skip: 3,
    expect: () => [
      isA<ChildProfileLoaded>()
          .having((s) => s.child.status, 'status', ChildStatus.inactive),
    ],
    verify: (_) =>
        verify(() => repo.setStatus('c1', ChildStatus.inactive)).called(1),
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'a failed write keeps the current child and carries the error',
    setUp: () {
      when(() => repo.fetchChild('c1')).thenAnswer((_) async => _child());
      when(() => repo.deletePhoto('c1')).thenThrow(
        const ApiException(code: 'FORBIDDEN', message: 'no', statusCode: 403),
      );
    },
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) async {
      await c.load();
      await c.deletePhoto();
    },
    skip: 3,
    expect: () => [
      isA<ChildProfileLoaded>()
          .having((s) => s.error?.code, 'error.code', 'FORBIDDEN')
          .having((s) => s.child.scanCode, 'child kept', 'SCAN-1'),
    ],
  );

  blocTest<ChildProfileCubit, ChildProfileState>(
    'mutations are ignored before the child has loaded',
    build: () => ChildProfileCubit(repo, 'c1'),
    act: (c) => c.regenerateScanCode(),
    expect: () => const <ChildProfileState>[],
    verify: (_) => verifyNever(() => repo.regenerateScanCode(any())),
  );
}
