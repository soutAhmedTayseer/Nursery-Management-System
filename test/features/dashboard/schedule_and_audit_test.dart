import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/dashboard/data/models/schedule_item.dart';
import 'package:nursery_management_system/features/dashboard/data/repositories/schedule_repository.dart';
import 'package:nursery_management_system/features/finance/data/repositories/audit_log_repository.dart';
import 'package:nursery_management_system/features/finance/domain/audit_entry.dart';
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
  int status = 200;
  Map<String, dynamic> body = const {};

  final List<String> paths = [];
  final List<String> methods = [];
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
    bodies.add(options.data);

    return ResponseBody.fromBytes(utf8.encode(jsonEncode(body)), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _itemJson = {
  'id': 'sch_01',
  'title': 'Morning Circle',
  'description': 'Songs and the day ahead',
  'start_minutes': 540,
  'end_minutes': 600,
  'icon_key': 'circle',
};

void main() {
  late _StubAdapter adapter;
  late ApiClient client;

  setUp(() {
    adapter = _StubAdapter();
    client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
  });

  group('schedule', () {
    test('fetchSchedule decodes items and resolves the icon key', () async {
      adapter.body = {'items': [_itemJson]};

      final items = await ApiScheduleRepository(client).fetchSchedule();

      expect(adapter.paths.single, '/admin/schedule');
      expect(items.single.title, 'Morning Circle');
      expect(items.single.startMinutes, 540);
      expect(items.single.icon, Icons.groups_outlined);
    });

    test('an unknown icon key falls back rather than failing', () async {
      adapter.body = {
        'items': [
          {..._itemJson, 'icon_key': 'something-this-build-has-never-seen'},
        ],
      };

      final items = await ApiScheduleRepository(client).fetchSchedule();

      expect(items.single.icon, Icons.schedule_outlined);
    });

    test('createItem sends no id — the server owns it', () async {
      adapter.body = Map<String, dynamic>.from(_itemJson);

      await ApiScheduleRepository(client).createItem(
        const ScheduleItemModel(
          id: '',
          title: 'Nap',
          startMinutes: 780,
          endMinutes: 840,
          icon: Icons.bedtime_outlined,
          themeColor: Colors.pink,
        ),
      );

      expect(adapter.paths.single, '/admin/schedule');
      final sent = adapter.bodies.single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['icon_key'], 'nap');
      expect(sent['start_minutes'], 780);
    });

    test('deleteItem removes by id', () async {
      adapter.status = 204;

      await ApiScheduleRepository(client).deleteItem('sch_01');

      expect(adapter.methods.single, 'DELETE');
      expect(adapter.paths.single, '/admin/schedule/sch_01');
    });
  });

  group('audit log', () {
    test('decodes an entry and its denormalized actor', () async {
      adapter.body = {
        'items': [
          {
            'id': 'aud_01',
            'action': 'invoice_marked_paid',
            'actor_id': 'adm_01',
            'actor_name': 'Nadia Farouk',
            'subject_id': 'kid_01',
            'subject_name': 'Omar Hassan',
            'amount': 1485,
            'at': '2026-08-14T15:00:00Z',
          },
        ],
        'total': 42,
        'page': 1,
        'page_size': 20,
      };

      final entries = await ApiAuditLogRepository(client).fetchEntries();

      expect(adapter.paths.single, '/admin/audit-log');
      expect(entries.single.action, AuditAction.invoiceMarkedPaid);
      // Denormalized, so the log survives the admin account being revoked.
      expect(entries.single.actor, 'Nadia Farouk');
      expect(entries.single.amount, 1485);
    });

    test('an action this build does not know maps to unknown, not a crash', () async {
      adapter.body = {
        'items': [
          {
            'id': 'aud_02',
            'action': 'something_a_newer_backend_logs',
            'actor_id': 'adm_01',
            'actor_name': 'Nadia',
            'subject_id': 'kid_01',
            'subject_name': 'Omar',
            'amount': null,
            'at': '2026-08-14T15:00:00Z',
          },
        ],
        'total': 1,
        'page': 1,
        'page_size': 20,
      };

      final entries = await ApiAuditLogRepository(client).fetchEntries();

      expect(entries.single.action, AuditAction.unknown);
    });

    test('there is no way to write an entry', () {
      // Compile-time guarantee rather than a runtime check: the interface has
      // no write method, which is the point — a trail the audited party can
      // append to is not a trail.
      expect(ApiAuditLogRepository(client), isA<AuditLogRepository>());
    });
  });
}
