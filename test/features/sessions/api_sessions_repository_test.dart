import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/children/data/repositories/children_repository.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/api_sessions_repository.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/sessions_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockChildrenRepository extends Mock implements ChildrenRepository {}

ChildSummary _summary({
  String id = 'c1',
  ChildStatus status = ChildStatus.active,
  String scanCode = 'CHD-abc',
}) =>
    ChildSummary(
      id: id,
      fullName: 'Lina',
      dateOfBirth: DateTime(2022, 1, 15),
      enrollmentDate: DateTime(2026, 8, 1),
      nationality: 'Egyptian',
      religion: 'Muslim',
      homeAddress: 'Cairo',
      allergies: 'Peanuts',
      photoUrl: '',
      scanCode: scanCode,
      isActive: status == ChildStatus.active,
      approvalStatus: 'Approved',
      status: status,
      createdAt: DateTime(2026, 8, 1),
      currentPlan: const CurrentPlan(
        assignmentId: 'a1',
        planId: 'p1',
        planName: 'Full Day',
        startDate: null,
        durationHours: 8,
      ),
    );

void main() {
  late _MockChildrenRepository children;
  late ApiSessionsRepository repo;

  setUp(() {
    children = _MockChildrenRepository();
    repo = ApiSessionsRepository(children);
  });

  test('maps the children page into KidSessions with the server scan code',
      () async {
    when(() => children.fetchChildren(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          search: any(named: 'search'),
          activeOnly: any(named: 'activeOnly'),
        )).thenAnswer((_) async => PaginatedResult<ChildSummary>(
          items: [_summary(id: 'c1'), _summary(id: 'c2', status: ChildStatus.pending)],
          total: 2,
          page: 1,
          pageSize: 8,
        ));

    final page = await repo.fetchKidSessions(page: 1, pageSize: 8, query: 'li');

    expect(page.items, hasLength(2));
    expect(page.items.first.kid.qrPayload, 'CHD-abc');
    expect(page.items.first.planLabel, 'Full Day');
    expect(page.items.first.isCheckedIn, isFalse);
    expect(page.items.first.kid.status, KidStatus.active);
    expect(page.items[1].kid.status, KidStatus.pendingApproval);

    final passed = verify(() => children.fetchChildren(
          page: 1,
          pageSize: 8,
          search: captureAny(named: 'search'),
          activeOnly: false,
        )).captured;
    expect(passed.single, 'li');
  });

  test('attendance actions are inert until Phase 2', () async {
    expect(await repo.checkIn('c1'), isNull);
    expect(await repo.checkOut('c1'), isNull);
    expect(await repo.clockToggle('c1'), isNull);
    expect(await repo.fetchAttendanceCounts(), (checkedIn: 0, checkedOut: 0));
  });

  test('updateKidPhoto forwards to POST /api/children/{id}/photo', () async {
    when(() => children.uploadPhoto('c1', '/tmp/p.jpg'))
        .thenAnswer((_) async => throw UnimplementedError());
    await repo.updateKidPhoto('c1', '/tmp/p.jpg').catchError((_) {});
    verify(() => children.uploadPhoto('c1', '/tmp/p.jpg')).called(1);
  });

  test('implements the SessionsRepository contract', () {
    expect(repo, isA<SessionsRepository>());
  });
}
