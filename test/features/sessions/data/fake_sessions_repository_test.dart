import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/core/testing/fake_failure_switch.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/fake_sessions_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  late FakeFailureSwitch failureSwitch;
  late FakeSessionsRepository repository;

  setUp(() {
    failureSwitch = FakeFailureSwitch();
    repository = FakeSessionsRepository(
      failureSwitch: failureSwitch,
      latency: Duration.zero,
    );
  });

  test('returns the requested page and the unpaginated total', () async {
    final result = await repository.fetchKidSessions(page: 1, pageSize: 8);
    expect(result.items.length, 8);
    expect(result.total, greaterThan(8));
    expect(result.page, 1);
  });

  test('the second page continues where the first ended', () async {
    final first = await repository.fetchKidSessions(page: 1, pageSize: 8);
    final second = await repository.fetchKidSessions(page: 2, pageSize: 8);
    final firstIds = first.items.map((e) => e.kid.id).toSet();
    final secondIds = second.items.map((e) => e.kid.id).toSet();
    expect(firstIds.intersection(secondIds), isEmpty);
  });

  test('filters by name, case-insensitively, and totals the matches',
      () async {
    final result = await repository.fetchKidSessions(
      page: 1,
      pageSize: 8,
      query: 'lEo',
    );
    expect(result.total, 1);
    expect(result.items.single.kid.fullName, contains('Leo'));
  });

  test('an out-of-range page yields no items but keeps the real total',
      () async {
    final result = await repository.fetchKidSessions(page: 99, pageSize: 8);
    expect(result.items, isEmpty);
    expect(result.total, greaterThan(0));
  });

  test('throws ApiException when the failure switch is on', () async {
    failureSwitch.enabled = true;
    expect(
      () => repository.fetchKidSessions(page: 1, pageSize: 8),
      throwsA(isA<ApiException>()),
    );
  });

  test('a checked-in kid reports an elapsed duration', () async {
    final result = await repository.fetchKidSessions(page: 1, pageSize: 20);
    final checkedIn = result.items.where((e) => e.isCheckedIn);
    expect(checkedIn, isNotEmpty);
    expect(checkedIn.first.elapsed, isNotNull);
  });
}
