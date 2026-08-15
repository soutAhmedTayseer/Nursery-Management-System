import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/kids/data/repositories/api_kids_repository.dart';
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

/// Records every request and replies with one canned body.
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
  'allergies': 'Peanuts',
  'medical_notes': null,
  'emergency_contact_name': 'Layla Hassan',
  'emergency_contact_phone': '+971500000001',
  'created_by': 'admin',
  'created_at': '2026-02-01T09:00:00Z',
  'approved_at': '2026-02-01T09:00:00Z',
  'approved_by': 'adm_01',
};

void main() {
  late _StubAdapter adapter;
  late ApiKidsRepository repository;

  setUp(() {
    adapter = _StubAdapter(body: Map<String, dynamic>.from(_kidJson));
    final client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
    repository = ApiKidsRepository(client);
  });

  group('fetchKids', () {
    test('sends paging and status filter, decodes the envelope', () async {
      adapter.body = {
        'items': [_kidJson],
        'total': 34,
        'page': 2,
        'page_size': 20,
      };

      final result = await repository.fetchKids(
        page: 2,
        pageSize: 20,
        status: KidStatus.active,
        query: '  omar  ',
      );

      expect(adapter.paths.single, '/kids');
      expect(adapter.queries.single, {
        'page': 2,
        'page_size': 20,
        'status': 'active',
        'query': 'omar', // trimmed
      });
      // total is the count of all matching rows, not items.length.
      expect(result.total, 34);
      expect(result.items.single.fullName, 'Omar Hassan');
    });

    test('omits status and query when they are not set', () async {
      adapter.body = {'items': [], 'total': 0, 'page': 1, 'page_size': 20};

      await repository.fetchKids();

      expect(adapter.queries.single.containsKey('status'), isFalse);
      expect(adapter.queries.single.containsKey('query'), isFalse);
    });
  });

  group('createKid', () {
    test('sends no id and no qr_payload — the server owns both', () async {
      await repository.createKid(
        fullName: 'Omar Hassan',
        dateOfBirth: DateTime(2022, 4, 18),
        emergencyContactName: 'Layla Hassan',
        emergencyContactPhone: '+971500000001',
        allergies: 'Peanuts',
      );

      final sent = adapter.bodies.single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent.containsKey('qr_payload'), isFalse);
      expect(sent['date_of_birth'], '2022-04-18');
      // No photo collected at registration, so none is sent.
      expect(sent.containsKey('photo_url'), isFalse);
    });

    test('returns the kid built from the server response', () async {
      final kid = await repository.createKid(
        fullName: 'Omar Hassan',
        dateOfBirth: DateTime(2022, 4, 18),
        emergencyContactName: 'Layla Hassan',
        emergencyContactPhone: '+971500000001',
      );

      expect(kid.id, 'kid_01');
      expect(kid.qrPayload, 'kid_01.server-signed');
      // Null on the wire maps to empty, not a crash.
      expect(kid.photoUrl, '');
    });
  });

  test('updateKid sends only the fields given', () async {
    await repository.updateKid('kid_01', photoUrl: 'https://cdn/x.jpg');

    expect(adapter.methods.single, 'PATCH');
    expect(adapter.paths.single, '/kids/kid_01');
    expect(adapter.bodies.single, {'photo_url': 'https://cdn/x.jpg'});
  });

  group('lifecycle actions', () {
    test('each hits its own endpoint', () async {
      await repository.approve('kid_01');
      await repository.waitlist('kid_01');
      await repository.activate('kid_01');
      await repository.deactivate('kid_01');

      expect(adapter.paths, [
        '/admin/kids/kid_01/approve',
        '/admin/kids/kid_01/waitlist',
        '/admin/kids/kid_01/activate',
        '/admin/kids/kid_01/deactivate',
      ]);
      expect(adapter.methods.every((m) => m == 'POST'), isTrue);
    });

    test('reject carries the reason', () async {
      await repository.reject('kid_01', reason: 'Incomplete medical info');

      expect(adapter.paths.single, '/admin/kids/kid_01/reject');
      expect(adapter.bodies.single, {'reason': 'Incomplete medical info'});
    });
  });

  test('propagates the backend error code', () async {
    adapter
      ..status = 404
      ..body = {
        'error': {'code': 'KID_NOT_FOUND', 'message': 'Kid not found'},
      };

    await expectLater(
      () => repository.fetchKid('kid_99'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'KID_NOT_FOUND')),
    );
  });
}
