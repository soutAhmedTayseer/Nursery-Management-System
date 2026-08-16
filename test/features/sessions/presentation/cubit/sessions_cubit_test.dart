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

  setUp(() {
    repository = _MockSessionsRepository();
    // Every _fetch() also reads the roster-wide counts; without this stub
    // mocktail returns null and each fetch blows up before emitting Loaded.
    when(() => repository.fetchAttendanceCounts())
        .thenAnswer((_) async => (checkedIn: 0, checkedOut: 0));
  });

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
    'updateKidPhoto writes through to the repository and refetches',
    setUp: () {
      when(() => repository.updateKidPhoto(any(), any())).thenAnswer((_) async {});
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => PaginatedResult<KidSession>(
            items: [_kidSession('1', 'Leo Maxwell')],
            total: 1,
            page: 1,
            pageSize: 8,
          ));
    },
    build: build,
    act: (cubit) => cubit.updateKidPhoto('1', 'C:/tmp/leo.png'),
    verify: (_) {
      verify(() => repository.updateKidPhoto('1', 'C:/tmp/leo.png')).called(1);
      verify(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).called(1);
    },
    expect: () => [isA<SessionsLoading>(), isA<SessionsLoaded>()],
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

  // --- Writes -------------------------------------------------------------
  //
  // These had no coverage at all, which is how the swallowed-error bug
  // survived: `clockIn` awaited the repository outside its try block, so a 409
  // escaped as an unhandled async error and the button silently did nothing.

  group('writes', () {
    // Registered here rather than inside a test body: starting a `when()` mid
    // test leaves mocktail's argument matchers dangling and the next stubbed
    // call fails with "an ArgumentMatcher was declared as named page".
    //
    // `filter` is deliberately not matched. It is a non-nullable enum, so
    // `any(named: 'filter')` needs a registered fallback value and throws
    // without one — mid-`when()`, which is exactly what leaves those matchers
    // dangling. Omitting it matches the default, which is all these need.
    setUp(() {
      when(() => repository.fetchKidSessions(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => PaginatedResult<KidSession>(
            items: [_kidSession('1', 'Leo Maxwell')],
            total: 1,
            page: 1,
            pageSize: 8,
          ));
    });

    const alreadyIn = ApiException(
      code: 'KID_ALREADY_CHECKED_IN',
      message: 'Kid is already checked in',
      statusCode: 409,
    );

    blocTest<SessionsCubit, SessionsState>(
      'clockIn refreshes the roster on success',
      setUp: () {
        when(() => repository.checkIn(any())).thenAnswer((_) async => null);
      },
      build: build,
      act: (cubit) => cubit.clockIn('1'),
      expect: () => [isA<SessionsLoading>(), isA<SessionsLoaded>()],
      verify: (_) => verify(() => repository.checkIn('1')).called(1),
    );

    blocTest<SessionsCubit, SessionsState>(
      'a rejected clockIn reports the failure and keeps the roster on screen',
      setUp: () {
        when(() => repository.checkIn(any())).thenThrow(alreadyIn);
      },
      build: build,
      act: (cubit) async {
        await cubit.loadSessions();
        await cubit.clockIn('1');
      },
      skip: 2, // the initial load
      expect: () => [
        isA<SessionsActionFailed>()
            .having((s) => s.exception.code, 'code', 'KID_ALREADY_CHECKED_IN'),
        // The list comes straight back, so one rejected row does not blank the
        // page the way SessionsError would.
        isA<SessionsLoaded>().having((s) => s.items.length, 'items', 1),
      ],
    );

    blocTest<SessionsCubit, SessionsState>(
      'a rejected clockOut is reported too',
      setUp: () {
        when(() => repository.checkOut(any())).thenThrow(const ApiException(
          code: 'KID_NOT_CHECKED_IN',
          message: 'Kid is not checked in',
          statusCode: 409,
        ));
      },
      build: build,
      act: (cubit) async {
        await cubit.loadSessions();
        await cubit.clockOut('1');
      },
      skip: 2,
      expect: () => [
        isA<SessionsActionFailed>()
            .having((s) => s.exception.code, 'code', 'KID_NOT_CHECKED_IN'),
        isA<SessionsLoaded>(),
      ],
    );

    test('handleQrScan returns the kid name on a good scan', () async {
      when(() => repository.clockToggle(any()))
          .thenAnswer((_) async => _kidSession('1', 'Leo Maxwell'));

      expect(await build().handleQrScan('kid_01.sig'), 'Leo Maxwell');
    });

    test('handleQrScan returns null for an unrecognized payload', () async {
      when(() => repository.clockToggle(any())).thenAnswer((_) async => null);

      // A 404 is not an error here — the screen renders it as "unrecognized".
      expect(await build().handleQrScan('nonsense'), isNull);
    });

    test('handleQrScan returns null and reports a rejected scan', () async {
      when(() => repository.clockToggle(any())).thenThrow(alreadyIn);
      final cubit = build();

      // Set up before acting: cubit streams deliver asynchronously, so
      // collecting into a list and cancelling straight after the await races
      // the delivery and sees nothing.
      final failure = expectLater(
        cubit.stream,
        emitsThrough(isA<SessionsActionFailed>()),
      );

      expect(await cubit.handleQrScan('kid_01.sig'), isNull);
      await failure;
    });
  });
}
