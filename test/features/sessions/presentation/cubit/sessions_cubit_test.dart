import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/sessions/data/models/kid_session.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/sessions_repository.dart';
import 'package:nursery_management_system/features/sessions/presentation/cubit/sessions_cubit.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

KidSession _kidSession(String id, String name) => KidSession(
      kid: Kid(
        id: id,
        fullName: name,
        dateOfBirth: DateTime(2021, 1, 1),
        photoUrl: '',
        status: KidStatus.active,
        allergies: null,
        medicalNotes: null,
        emergencyContactName: 'x',
        emergencyContactPhone: 'y',
        createdBy: 'admin',
        createdAt: DateTime(2026, 1, 1),
        approvedAt: null,
        approvedBy: null,
      ),
      activeSession: null,
      planLabel: 'Full-time',
    );

void main() {
  late _MockSessionsRepository repository;

  setUp(() => repository = _MockSessionsRepository());

  SessionsCubit build() => SessionsCubit(repository);

  test('starts in SessionsInitial', () {
    expect(build().state, isA<SessionsInitial>());
  });

  blocTest<SessionsCubit, SessionsState>(
    'emits Loading then Loaded with the repository page',
    setUp: () {
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => PaginatedResult<KidSession>(
            items: [_kidSession('1', 'Leo Maxwell')],
            total: 12,
            page: 1,
            pageSize: 8,
          ));
    },
    build: build,
    act: (cubit) => cubit.loadSessions(),
    expect: () => [
      isA<SessionsLoading>(),
      isA<SessionsLoaded>()
          .having((s) => s.items.length, 'items', 1)
          .having((s) => s.totalCount, 'totalCount', 12)
          .having((s) => s.totalPages, 'totalPages', 2),
    ],
  );

  blocTest<SessionsCubit, SessionsState>(
    'emits SessionsError carrying the ApiException on failure',
    setUp: () {
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenThrow(const ApiException(
        code: 'NETWORK_ERROR',
        message: 'boom',
        statusCode: null,
      ));
    },
    build: build,
    act: (cubit) => cubit.loadSessions(),
    expect: () => [
      isA<SessionsLoading>(),
      isA<SessionsError>()
          .having((s) => s.exception.code, 'code', 'NETWORK_ERROR'),
    ],
  );

  blocTest<SessionsCubit, SessionsState>(
    'search resets to page 1 and passes the query to the repository',
    setUp: () {
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => const PaginatedResult<KidSession>(
            items: [],
            total: 0,
            page: 1,
            pageSize: 8,
          ));
    },
    build: build,
    act: (cubit) async {
      await cubit.changePage(3);
      await cubit.search('leo');
    },
    verify: (_) {
      verify(() => repository.fetchKidSessions(
            page: 1,
            pageSize: 8,
            query: 'leo',
          )).called(1);
    },
  );

  blocTest<SessionsCubit, SessionsState>(
    'a slower first search response does not overwrite a faster later one',
    setUp: () {
      var call = 0;
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((invocation) async {
        call += 1;
        final query = invocation.namedArguments[#query] as String;
        if (call == 1) {
          // First call ("leo") resolves after the second ("noah").
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        return PaginatedResult<KidSession>(
          items: [_kidSession(query, query)],
          total: 1,
          page: 1,
          pageSize: 8,
        );
      });
    },
    build: build,
    act: (cubit) async {
      final first = cubit.search('leo');
      final second = cubit.search('noah');
      await Future.wait([first, second]);
    },
    expect: () => [
      isA<SessionsLoading>(),
      isA<SessionsLoading>(),
      isA<SessionsLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'noah'),
    ],
  );

  blocTest<SessionsCubit, SessionsState>(
    'emits an empty Loaded state when nothing matches',
    setUp: () {
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => const PaginatedResult<KidSession>(
            items: [],
            total: 0,
            page: 1,
            pageSize: 8,
          ));
    },
    build: build,
    act: (cubit) => cubit.loadSessions(),
    expect: () => [
      isA<SessionsLoading>(),
      isA<SessionsLoaded>().having((s) => s.items, 'items', isEmpty),
    ],
  );
}
