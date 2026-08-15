import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/kids/data/repositories/kids_repository.dart';
import 'package:nursery_management_system/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:nursery_management_system/features/registration/presentation/cubit/registration_state.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/sessions_repository.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockKidsRepository extends Mock implements KidsRepository {}

class _MockSessionsRepository extends Mock implements SessionsRepository {}

final _serverKid = Kid(
  // Deliberately unlike anything the client could mint from a timestamp.
  id: 'kid_from_server',
  fullName: 'Omar Hassan',
  dateOfBirth: DateTime(2022, 4, 18),
  photoUrl: '',
  status: KidStatus.active,
  allergies: null,
  medicalNotes: null,
  emergencyContactName: 'Layla Hassan',
  emergencyContactPhone: '+971500000001',
  createdBy: 'admin',
  createdAt: DateTime(2026, 8, 15),
  approvedAt: DateTime(2026, 8, 15),
  approvedBy: 'adm_01',
  qrPayload: 'kid_from_server.server-signed',
);

const _category = PlanCategory(
  id: 'cat_01',
  name: 'Monthly Packages',
  icon: Icons.calendar_month,
  themeColor: Color(0xFF000000),
  isFeatured: false,
  lineItems: [_item],
);

const _item = PlanLineItem(
  id: 'item_01',
  label: '3 hours / 5 Days',
  price: 'AED 1,200',
  daysPerCycle: 5,
);

void main() {
  late _MockKidsRepository kids;
  late _MockSessionsRepository sessions;

  setUpAll(() {
    registerFallbackValue(_serverKid);
  });

  setUp(() {
    kids = _MockKidsRepository();
    sessions = _MockSessionsRepository();
    when(() => sessions.addKid(any(), planLabel: any(named: 'planLabel')))
        .thenAnswer((_) async {});
  });

  void register(RegistrationCubit cubit) => cubit.registerChild(
        fullName: 'Omar Hassan',
        dateOfBirth: DateTime(2022, 4, 18),
        planCategory: _category,
        planItem: _item,
        parentName: 'Layla Hassan',
        parentPhone: '+971500000001',
      );

  blocTest<RegistrationCubit, RegistrationState>(
    'emits Loading then Success carrying the server-assigned id',
    setUp: () {
      when(() => kids.createKid(
            fullName: any(named: 'fullName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            emergencyContactName: any(named: 'emergencyContactName'),
            emergencyContactPhone: any(named: 'emergencyContactPhone'),
            allergies: any(named: 'allergies'),
          )).thenAnswer((_) async => _serverKid);
    },
    build: () => RegistrationCubit(kids, sessions),
    act: register,
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationSuccess>().having(
        (s) => s.assignment.kidId,
        'kidId',
        // The whole point: the id comes from the response, not from a
        // locally generated timestamp.
        'kid_from_server',
      ),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'still adds the new child to the sessions roster',
    setUp: () {
      when(() => kids.createKid(
            fullName: any(named: 'fullName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            emergencyContactName: any(named: 'emergencyContactName'),
            emergencyContactPhone: any(named: 'emergencyContactPhone'),
            allergies: any(named: 'allergies'),
          )).thenAnswer((_) async => _serverKid);
    },
    build: () => RegistrationCubit(kids, sessions),
    act: register,
    verify: (_) {
      // Sessions is still fake this phase; without this the child would be
      // created and then vanish from the roster.
      verify(() => sessions.addKid(_serverKid,
          planLabel: 'Monthly Packages · 3 hours / 5 Days')).called(1);
    },
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'emits a localized Error when the API rejects the kid',
    setUp: () {
      when(() => kids.createKid(
            fullName: any(named: 'fullName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            emergencyContactName: any(named: 'emergencyContactName'),
            emergencyContactPhone: any(named: 'emergencyContactPhone'),
            allergies: any(named: 'allergies'),
          )).thenThrow(const ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Request failed validation',
        statusCode: 400,
      ));
    },
    build: () => RegistrationCubit(kids, sessions),
    act: register,
    expect: () => [isA<RegistrationLoading>(), isA<RegistrationError>()],
    verify: (_) {
      verifyNever(() => sessions.addKid(any(), planLabel: any(named: 'planLabel')));
    },
  );
}
