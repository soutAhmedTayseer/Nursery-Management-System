import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/children/data/repositories/api_children_repository.dart';
import 'package:nursery_management_system/features/children/data/repositories/children_repository.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _InMemoryTokenStorage implements TokenStorage {
  String? access = 'token';
  @override
  Future<String?> readAccessToken() async => access;
  @override
  Future<String?> readRefreshToken() async => 'refresh';
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> clear() async => access = null;
}

/// Replies keyed by "METHOD path"; records the body and query of each call.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.replies);

  final Map<String, (int, dynamic)> replies;
  final List<String> calls = [];
  final Map<String, Object?> bodyByKey = {};
  final Map<String, Map<String, dynamic>> queryByKey = {};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = '${options.method} ${options.path}';
    calls.add(key);
    final data = options.data;
    if (data is String) {
      bodyByKey[key] = jsonDecode(data);
    } else if (data is! FormData) {
      bodyByKey[key] = data;
    } else {
      bodyByKey[key] = {'_multipart': true};
    }
    queryByKey[key] = options.queryParameters;
    final reply = replies[key] ?? replies['* ${options.path}'];
    if (reply == null) throw StateError('no stub for $key');
    final (status, body) = reply;
    return ResponseBody.fromBytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _childJson(String id, {String status = 'Active'}) => {
      'id': id,
      'fullName': 'Lina Hassan',
      'dateOfBirth': '2022-01-15',
      'enrollmentDate': '2026-08-01',
      'nationality': 'Egyptian',
      'religion': '',
      'homeAddress': 'Cairo',
      'allergies': null,
      'photoUrl': null,
      'scanCode': 'SCAN-1',
      'isActive': status == 'Active',
      'approvalStatus': 'Approved',
      'status': status,
      'createdAt': '2026-08-01T00:00:00Z',
      'createdBy': null,
      'approvedAt': null,
      'approvedBy': null,
      'mother': null,
      'father': null,
      'agreement': null,
      'emergencyContacts': <dynamic>[],
      'currentPlan': null,
    };

ApiChildrenRepository _repo(_StubAdapter adapter) {
  final client = ApiClient(
    baseUrl: 'https://api.test',
    tokenStorage: _InMemoryTokenStorage(),
  )..dio.httpClientAdapter = adapter;
  return ApiChildrenRepository(client);
}

final _input = ChildInput(
  fullName: 'Lina Hassan',
  dateOfBirth: DateTime(2022, 1, 15),
  enrollmentDate: DateTime(2026, 8, 1),
  nationality: 'Egyptian',
  religion: '',
  homeAddress: 'Cairo',
  allergies: null,
  mother: const ParentContact(
    fullName: 'Mona',
    phone: '+201',
    email: 'm@e.com',
    occupation: '',
    jobTitle: '',
    companyName: '',
    workPhone: '',
    address: 'Cairo',
  ),
  father: const ParentContact(
    fullName: 'Sam',
    phone: '+202',
    email: 's@e.com',
    occupation: '',
    jobTitle: '',
    companyName: '',
    workPhone: '',
    address: 'Cairo',
  ),
  agreement: ChildAgreement(
    mediaPermission: true,
    parentSignature: 'Mona',
    signedDate: DateTime(2026, 8, 1),
    acceptedTerms: true,
  ),
  emergencyContacts: const [
    NewEmergencyContact(
        name: 'Gran', relationship: 'Relative', phone: '+203'),
  ],
);

void main() {
  test('fetchChildren sends paging + filter query and parses the wrapper',
      () async {
    final adapter = _StubAdapter({
      'GET /children': (
        200,
        {
          'items': [_childJson('c1'), _childJson('c2', status: 'Inactive')],
          'pageNumber': 1,
          'pageSize': 20,
          'totalCount': 2,
          'totalPages': 1,
        }
      ),
    });

    final page = await _repo(adapter)
        .fetchChildren(page: 1, pageSize: 20, search: 'lin', activeOnly: true);

    expect(page.items, hasLength(2));
    expect(page.items.first.status, ChildStatus.active);
    expect(page.total, 2);
    expect(adapter.queryByKey['GET /children'], {
      'pageNumber': 1,
      'pageSize': 20,
      'search': 'lin',
      'activeOnly': true,
    });
  });

  test('fetchChild parses ChildDetailsDto', () async {
    final adapter = _StubAdapter({'GET /children/c1': (200, _childJson('c1'))});
    final child = await _repo(adapter).fetchChild('c1');
    expect(child.id, 'c1');
    expect(child.scanCode, 'SCAN-1');
  });

  test('createChild posts the command then finds the row in the roster',
      () async {
    final adapter = _StubAdapter({
      'POST /children': (200, ''),
      'GET /children': (
        200,
        {
          'items': [_childJson('new-1')],
          'pageNumber': 1,
          'pageSize': 50,
          'totalCount': 1,
        }
      ),
    });

    final created = await _repo(adapter).createChild(_input);

    expect(created?.id, 'new-1');
    final body = adapter.bodyByKey['POST /children']! as Map<String, dynamic>;
    expect(body['fullName'], 'Lina Hassan');
    expect(body['dateOfBirth'], '2022-01-15');
    expect(body['mother'], isA<Map<String, dynamic>>());
    expect((body['emergencyContacts'] as List), hasLength(1));
  });

  test('updateChild PUTs the command (no emergencyContacts) then re-reads',
      () async {
    final adapter = _StubAdapter({
      'PUT /children/c1': (200, ''),
      'GET /children/c1': (200, _childJson('c1')),
    });

    final child = await _repo(adapter).updateChild('c1', _input);

    expect(child.id, 'c1');
    final body = adapter.bodyByKey['PUT /children/c1']! as Map<String, dynamic>;
    expect(body.containsKey('emergencyContacts'), isFalse);
    expect(body['enrollmentDate'], '2026-08-01');
  });

  test('setActive sends {id,isActive} and re-reads', () async {
    final adapter = _StubAdapter({
      'PUT /children/c1/active': (200, ''),
      'GET /children/c1': (200, _childJson('c1')),
    });

    await _repo(adapter).setActive('c1', isActive: false);

    expect(adapter.bodyByKey['PUT /children/c1/active'],
        {'id': 'c1', 'isActive': false});
  });

  test('setStatus sends the PascalCase wire value', () async {
    final adapter = _StubAdapter({
      'PUT /children/c1/status': (200, ''),
      'GET /children/c1': (200, _childJson('c1', status: 'Rejected')),
    });

    final child = await _repo(adapter).setStatus('c1', ChildStatus.rejected);

    expect(adapter.bodyByKey['PUT /children/c1/status'], {'status': 'Rejected'});
    expect(child.status, ChildStatus.rejected);
  });

  test('regenerateScanCode POSTs then re-reads the fresh code', () async {
    final adapter = _StubAdapter({
      'POST /children/c1/scan-code/regenerate': (200, ''),
      'GET /children/c1': (
        200,
        {..._childJson('c1'), 'scanCode': 'SCAN-2'}
      ),
    });

    final child = await _repo(adapter).regenerateScanCode('c1');

    expect(child.scanCode, 'SCAN-2');
    expect(adapter.calls, contains('POST /children/c1/scan-code/regenerate'));
  });

  test('uploadPhoto sends multipart then re-reads', () async {
    final tmp = File('${Directory.systemTemp.path}/child_photo_test.bin')
      ..writeAsBytesSync(const [1, 2, 3]);
    final adapter = _StubAdapter({
      'POST /children/c1/photo': (200, ''),
      'GET /children/c1': (
        200,
        {..._childJson('c1'), 'photoUrl': 'https://cdn/p.jpg'}
      ),
    });

    final child = await _repo(adapter).uploadPhoto('c1', tmp.path);

    expect(child.photoUrl, 'https://cdn/p.jpg');
    expect(adapter.bodyByKey['POST /children/c1/photo'], {'_multipart': true});
  });

  test('deletePhoto DELETEs then re-reads', () async {
    final adapter = _StubAdapter({
      'DELETE /children/c1/photo': (200, ''),
      'GET /children/c1': (200, _childJson('c1')),
    });

    await _repo(adapter).deletePhoto('c1');

    expect(adapter.calls, contains('DELETE /children/c1/photo'));
  });

  test('addEmergencyContact posts {childId,...} then re-reads', () async {
    final adapter = _StubAdapter({
      'POST /children/c1/emergency-contacts': (200, ''),
      'GET /children/c1': (200, _childJson('c1')),
    });

    await _repo(adapter).addEmergencyContact(
      'c1',
      const NewEmergencyContact(
          name: 'Gran', relationship: 'Relative', phone: '+203'),
    );

    expect(adapter.bodyByKey['POST /children/c1/emergency-contacts'], {
      'childId': 'c1',
      'name': 'Gran',
      'relationship': 'Relative',
      'phone': '+203',
    });
  });

  test('removeEmergencyContact DELETEs the nested path then re-reads', () async {
    final adapter = _StubAdapter({
      'DELETE /children/c1/emergency-contacts/ec9': (200, ''),
      'GET /children/c1': (200, _childJson('c1')),
    });

    await _repo(adapter).removeEmergencyContact('c1', 'ec9');

    expect(adapter.calls, contains('DELETE /children/c1/emergency-contacts/ec9'));
  });

  test('surfaces Problem Details as ApiException with a stable code', () async {
    final adapter = _StubAdapter({
      'GET /children/c1': (
        404,
        {'code': 'CHILD_NOT_FOUND', 'detail': 'gone', 'title': 'Not Found'}
      ),
    });

    await expectLater(
      () => _repo(adapter).fetchChild('c1'),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'CHILD_NOT_FOUND')),
    );
  });
}
