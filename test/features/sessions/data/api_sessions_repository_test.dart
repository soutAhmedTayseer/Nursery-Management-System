import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/api_sessions_repository.dart';
import 'package:nursery_management_system/features/sessions/data/repositories/sessions_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _NoTokens implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
  @override
  Future<void> clear() async {}
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.body = const {}});

  int status = 200;
  Map<String, dynamic> body;

  final List<String> paths = [];
  final List<String> methods = [];
  final List<Map<String, dynamic>> queries = [];
  final List<dynamic> bodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    methods.add(options.method);
    queries.add(options.queryParameters);
    bodies.add(options.data);

    return ResponseBody.fromBytes(utf8.encode(jsonEncode(body)), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _kidJson = {
  'id': 'kid_01',
  'full_name': 'Omar Hassan',
  'date_of_birth': '2022-04-18',
  'photo_url': null,
  'qr_payload': 'kid_01.server-signed',
  'status': 'active',
  'allergies': null,
  'medical_notes': null,
  'emergency_contact_name': 'Layla Hassan',
  'emergency_contact_phone': '+971500000001',
  'created_by': 'admin',
  'created_at': '2026-02-01T09:00:00Z',
  'approved_at': '2026-02-01T09:00:00Z',
  'approved_by': 'adm_01',
};

const _sessionJson = {
  'id': 'ses_01',
  'kid_id': 'kid_01',
  'requested_by': 'admin',
  'requested_by_id': 'adm_01',
  'status': 'confirmed',
  'checked_in_at': '2026-08-15T07:32:00Z',
  'confirmed_by': 'adm_01',
  'checked_out_at': null,
  'checked_out_confirmed_by': null,
  'hours_deducted': null,
  'subscription_id': 'sub_01',
};

const _rosterItem = {
  'kid': _kidJson,
  'active_session': _sessionJson,
  'plan_label': 'Monthly Packages · 3 hours / 5 Days',
};

Map<String, dynamic> _rosterBody({
  List<Map<String, dynamic>> items = const [_rosterItem],
  int total = 34,
  int checkedIn = 23,
  int checkedOut = 11,
}) =>
    {
      'items': items,
      'total': total,
      'page': 1,
      'page_size': 8,
      'checked_in_count': checkedIn,
      'checked_out_count': checkedOut,
    };

void main() {
  late _StubAdapter adapter;
  late ApiSessionsRepository repository;

  setUp(() {
    adapter = _StubAdapter(body: _rosterBody());
    final client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
    repository = ApiSessionsRepository(client);
  });

  group('fetchKidSessions', () {
    test('reads the roster and decodes an item', () async {
      final result = await repository.fetchKidSessions(page: 1, pageSize: 8);

      expect(adapter.paths.single, '/admin/roster');
      expect(result.total, 34);

      final item = result.items.single;
      expect(item.kid.fullName, 'Omar Hassan');
      expect(item.planLabel, 'Monthly Packages · 3 hours / 5 Days');
      expect(item.isCheckedIn, isTrue);
    });

    test('maps each attendance filter to its wire value', () async {
      for (final (filter, wire) in [
        (AttendanceFilter.all, 'all'),
        (AttendanceFilter.checkedIn, 'checked_in'),
        (AttendanceFilter.checkedOut, 'checked_out'),
      ]) {
        await repository.fetchKidSessions(page: 1, pageSize: 8, filter: filter);
        expect(adapter.queries.last['attendance'], wire);
      }
    });

    test('trims the query and omits it when blank', () async {
      await repository.fetchKidSessions(page: 2, pageSize: 8, query: '  omar  ');
      expect(adapter.queries.last, {
        'page': 2,
        'page_size': 8,
        'query': 'omar',
        'attendance': 'all',
      });

      await repository.fetchKidSessions(page: 1, pageSize: 8, query: '   ');
      expect(adapter.queries.last.containsKey('query'), isFalse);
    });

    test('handles a null active_session', () async {
      adapter.body = _rosterBody(items: [
        {'kid': _kidJson, 'active_session': null, 'plan_label': 'Drop-in'},
      ]);

      final result = await repository.fetchKidSessions(page: 1, pageSize: 8);

      expect(result.items.single.activeSession, isNull);
      expect(result.items.single.isCheckedIn, isFalse);
    });
  });

  group('fetchAttendanceCounts', () {
    test('reuses the counts from the roster response, without a second call', () async {
      await repository.fetchKidSessions(page: 1, pageSize: 8);
      final counts = await repository.fetchAttendanceCounts();

      expect(counts.checkedIn, 23);
      expect(counts.checkedOut, 11);
      // The counts ride along on the roster response; asking for them must not
      // cost another round-trip.
      expect(adapter.paths, ['/admin/roster']);
    });
  });

  group('clock actions', () {
    test('checkIn and checkOut hit the direct admin endpoints', () async {
      adapter.body = Map<String, dynamic>.from(_rosterItem);

      await repository.checkIn('kid_01');
      await repository.checkOut('kid_01');

      expect(adapter.paths, [
        '/admin/kids/kid_01/sessions/direct-check-in',
        '/admin/kids/kid_01/sessions/direct-check-out',
      ]);
    });

    test('clockToggle sends the raw payload, never a decoded id', () async {
      adapter.body = Map<String, dynamic>.from(_rosterItem);

      final result = await repository.clockToggle('kid_01.server-signed');

      expect(adapter.paths.single, '/admin/sessions/qr-toggle');
      expect(adapter.bodies.single, {'qr_payload': 'kid_01.server-signed'});
      expect(result!.kid.fullName, 'Omar Hassan');
    });

    test('an unrecognized code returns null rather than throwing', () async {
      adapter
        ..status = 404
        ..body = {
          'error': {'code': 'KID_NOT_FOUND', 'message': 'No kid matches this QR code'},
        };

      expect(await repository.clockToggle('forged'), isNull);
    });

    test('a non-404 failure still surfaces', () async {
      adapter
        ..status = 409
        ..body = {
          'error': {'code': 'KID_NOT_ACTIVE', 'message': 'Kid is not active'},
        };

      await expectLater(
        () => repository.clockToggle('kid_01.server-signed'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'KID_NOT_ACTIVE')),
      );
    });
  });

  test('updateKidPhoto patches the kid', () async {
    adapter.body = Map<String, dynamic>.from(_kidJson);

    await repository.updateKidPhoto('kid_01', 'https://cdn/x.jpg');

    expect(adapter.methods.single, 'PATCH');
    expect(adapter.paths.single, '/kids/kid_01');
    expect(adapter.bodies.single, {'photo_url': 'https://cdn/x.jpg'});
  });

  test('addKid makes no request — the server already created them', () async {
    await repository.addKid(
      Kid.fromJson(Map<String, dynamic>.from(_kidJson)),
      planLabel: 'Drop-in',
    );

    expect(adapter.paths, isEmpty);
  });
}
