import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/subscriptions/data/repositories/api_plans_repository.dart';
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

const _planJson = {
  'id': 'pln_01',
  'name': '3 hours / 5 Days',
  'category': 'Monthly Packages',
  'hours_included': 60,
  'hours_per_day': 3,
  'days_per_cycle': 5,
  'price': 1200,
  'currency': 'AED',
  'badge_text': 'BEST VALUE',
  'is_featured': true,
  'active': true,
};

const _assignmentJson = {
  'kid_id': 'kid_01',
  'plan_id': 'pln_01',
  'plan_name': '3 hours / 5 Days',
  'plan_category': 'Monthly Packages',
  'assigned_at': '2026-08-01T07:15:00Z',
  'assigned_by': 'adm_01',
};

void main() {
  late _StubAdapter adapter;
  late ApiPlansRepository repository;

  setUp(() {
    adapter = _StubAdapter();
    final client = ApiClient(baseUrl: 'https://api.test', tokenStorage: _NoTokens())
      ..dio.httpClientAdapter = adapter;
    repository = ApiPlansRepository(client);
  });

  test('fetchPlans unwraps the paginated envelope', () async {
    adapter.body = {'items': [_planJson], 'total': 1, 'page': 1, 'page_size': 20};

    final plans = await repository.fetchPlans();

    expect(adapter.paths.single, '/plans');
    expect(plans.single.category, 'Monthly Packages');
    expect(plans.single.price, 1200);
  });

  test('createPlan omits the id — the server owns it', () async {
    adapter.body = Map<String, dynamic>.from(_planJson);

    await repository.createPlan(Plan.fromJson(Map<String, dynamic>.from(_planJson)));

    expect(adapter.paths.single, '/admin/plans');
    expect((adapter.bodies.single as Map).containsKey('id'), isFalse);
    expect((adapter.bodies.single as Map)['price'], 1200);
  });

  test('deactivatePlan patches active=false rather than deleting', () async {
    adapter.body = {..._planJson, 'active': false};

    await repository.deactivatePlan('pln_01');

    expect(adapter.methods.single, 'PATCH');
    expect(adapter.paths.single, '/admin/plans/pln_01');
    expect(adapter.bodies.single, {'active': false});
  });

  group('assignment', () {
    test('assignPlan PUTs the plan id and moves no money', () async {
      adapter.body = Map<String, dynamic>.from(_assignmentJson);

      final assignment = await repository.assignPlan('kid_01', 'pln_01');

      expect(adapter.methods.single, 'PUT');
      expect(adapter.paths.single, '/admin/kids/kid_01/plan');
      expect(adapter.bodies.single, {'plan_id': 'pln_01'});
      // No payment_method anywhere — assignment is not a purchase.
      expect((adapter.bodies.single as Map).containsKey('payment_method'), isFalse);
      expect(assignment.planName, '3 hours / 5 Days');
    });

    test('an unassigned kid reads as null, not an error', () async {
      adapter
        ..status = 404
        ..body = {
          'error': {'code': 'KID_NOT_FOUND', 'message': 'Kid has no plan assigned'},
        };

      expect(await repository.fetchAssignment('kid_01'), isNull);
    });

    test('a non-404 assignment read still surfaces', () async {
      adapter
        ..status = 403
        ..body = {
          'error': {'code': 'FORBIDDEN', 'message': 'Admin role required'},
        };

      await expectLater(
        () => repository.fetchAssignment('kid_01'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FORBIDDEN')),
      );
    });
  });

  test('recordPurchase carries the payment method', () async {
    adapter.body = {
      'id': 'sub_01',
      'kid_id': 'kid_01',
      'plan_id': 'pln_01',
      'hours_remaining': 60,
      'hours_total': 60,
      'purchased_at': '2026-08-01T07:15:00Z',
      'recorded_by': 'adm_01',
      'payment_method': 'cash',
      'notes': null,
      'status': 'active',
    };

    await repository.recordPurchase('kid_01', planId: 'pln_01', paymentMethod: 'cash');

    expect(adapter.paths.single, '/admin/kids/kid_01/subscriptions');
    expect(adapter.bodies.single, {'plan_id': 'pln_01', 'payment_method': 'cash'});
  });

  test('fetchPlanHistory unwraps the envelope newest-first', () async {
    adapter.body = {
      'items': [
        {
          'id': 'pch_01',
          'kid_id': 'kid_01',
          'old_plan_id': 'pln_00',
          'old_plan_name': '2 hours / 3 Days',
          'new_plan_id': 'pln_01',
          'new_plan_name': '3 hours / 5 Days',
          'changed_by': 'adm_01',
          'changed_at': '2026-08-01T07:15:00Z',
        },
      ],
      'total': 1,
      'page': 1,
      'page_size': 20,
    };

    final history = await repository.fetchPlanHistory('kid_01');

    expect(adapter.paths.single, '/admin/kids/kid_01/plan-history');
    expect(history.single.oldPlanName, '2 hours / 3 Days');
  });
}
