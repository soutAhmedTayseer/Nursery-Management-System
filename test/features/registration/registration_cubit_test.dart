import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/children/data/repositories/children_repository.dart';
import 'package:nursery_management_system/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:nursery_management_system/features/registration/presentation/cubit/registration_state.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockChildrenRepository extends Mock implements ChildrenRepository {}

final _input = ChildInput(
  fullName: 'Lina Hassan',
  dateOfBirth: DateTime(2022, 1, 15),
  enrollmentDate: DateTime(2026, 8, 30),
  nationality: 'Egyptian',
  religion: 'Muslim',
  homeAddress: 'Cairo',
  allergies: null,
  mother: const ParentContact(
    fullName: 'Mona',
    phone: '01000000001',
    email: 'mona@example.com',
    occupation: 'Doctor',
    jobTitle: 'GP',
    companyName: 'Clinic',
    workPhone: '01000000009',
    address: 'Cairo',
  ),
  father: const ParentContact(
    fullName: '',
    phone: '',
    email: '',
    occupation: '',
    jobTitle: '',
    companyName: '',
    workPhone: '',
    address: '',
  ),
  agreement: ChildAgreement(
    mediaPermission: true,
    parentSignature: 'Mona',
    signedDate: DateTime(2026, 8, 30),
    acceptedTerms: true,
  ),
  emergencyContacts: const [
    NewEmergencyContact(name: 'Sara', relationship: 'Aunt', phone: '01000000003'),
  ],
);

ChildSummary _summary() => ChildSummary(
      id: 'c-new',
      fullName: 'Lina Hassan',
      dateOfBirth: DateTime(2022, 1, 15),
      enrollmentDate: DateTime(2026, 8, 30),
      nationality: 'Egyptian',
      religion: 'Muslim',
      homeAddress: 'Cairo',
      allergies: null,
      photoUrl: '',
      scanCode: 'SCAN-NEW',
      isActive: false,
      approvalStatus: 'Pending',
      status: ChildStatus.pending,
      createdAt: DateTime(2026, 8, 30),
      currentPlan: null,
    );

void main() {
  late _MockChildrenRepository repo;

  setUp(() {
    repo = _MockChildrenRepository();
    registerFallbackValue(_input);
  });

  test('starts in RegistrationInitial', () {
    expect(RegistrationCubit(repo).state, isA<RegistrationInitial>());
  });

  blocTest<RegistrationCubit, RegistrationState>(
    'submit emits Loading then Success carrying the created child',
    setUp: () => when(() => repo.createChild(any()))
        .thenAnswer((_) async => _summary()),
    build: () => RegistrationCubit(repo),
    act: (c) => c.submit(_input),
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationSuccess>()
          .having((s) => s.child?.fullName, 'child', 'Lina Hassan'),
    ],
    verify: (_) => verify(() => repo.createChild(_input)).called(1),
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'submit still succeeds when the API gives back no row',
    setUp: () =>
        when(() => repo.createChild(any())).thenAnswer((_) async => null),
    build: () => RegistrationCubit(repo),
    act: (c) => c.submit(_input),
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationSuccess>().having((s) => s.child, 'child', isNull),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'submit surfaces the API error detail',
    setUp: () => when(() => repo.createChild(any())).thenThrow(
      const ApiException(
        code: 'VALIDATION_FAILED',
        message: 'dateOfBirth is required',
        statusCode: 400,
      ),
    ),
    build: () => RegistrationCubit(repo),
    act: (c) => c.submit(_input),
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationError>()
          .having((s) => s.message, 'message', 'dateOfBirth is required'),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'submit maps an unexpected error to a generic key',
    setUp: () =>
        when(() => repo.createChild(any())).thenThrow(Exception('boom')),
    build: () => RegistrationCubit(repo),
    act: (c) => c.submit(_input),
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationError>()
          .having((s) => s.message, 'message', 'registration_error_generic'),
    ],
  );
}
