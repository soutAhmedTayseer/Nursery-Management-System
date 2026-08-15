import 'package:nursery_shared/nursery_shared.dart';

import 'plans_repository.dart';

class ApiPlansRepository implements PlansRepository {
  ApiPlansRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Plan>> fetchPlans() async {
    final response = await _client.get<Map<String, dynamic>>('/plans');
    return PaginatedResult.fromJson(response.data!, Plan.fromJson).items;
  }

  @override
  Future<Plan> createPlan(Plan plan) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/plans',
      data: _body(plan),
    );
    return Plan.fromJson(response.data!);
  }

  @override
  Future<Plan> updatePlan(Plan plan) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/plans/${plan.id}',
      data: _body(plan),
    );
    return Plan.fromJson(response.data!);
  }

  @override
  Future<Plan> deactivatePlan(String planId) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/plans/$planId',
      data: {'active': false},
    );
    return Plan.fromJson(response.data!);
  }

  @override
  Future<PlanAssignmentRecord?> fetchAssignment(String kidId) async {
    try {
      final response =
          await _client.get<Map<String, dynamic>>('/admin/kids/$kidId/plan');
      return PlanAssignmentRecord.fromJson(response.data!);
    } on ApiException catch (exception) {
      // Unassigned is a normal state, not a failure.
      if (exception.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<PlanAssignmentRecord> assignPlan(String kidId, String planId) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/admin/kids/$kidId/plan',
      data: {'plan_id': planId},
    );
    return PlanAssignmentRecord.fromJson(response.data!);
  }

  @override
  Future<List<PlanChange>> fetchPlanHistory(String kidId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/admin/kids/$kidId/plan-history',
    );
    return PaginatedResult.fromJson(response.data!, PlanChange.fromJson).items;
  }

  @override
  Future<Subscription> recordPurchase(
    String kidId, {
    required String planId,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/kids/$kidId/subscriptions',
      data: {
        'plan_id': planId,
        'payment_method': paymentMethod,
        'notes': ?notes,
      },
    );
    return Subscription.fromJson(response.data!);
  }

  /// `id` is omitted — the server owns it on create, and it is in the path on
  /// update.
  static Map<String, dynamic> _body(Plan plan) => {
        'name': plan.name,
        'category': plan.category,
        'hours_included': plan.hoursIncluded,
        'hours_per_day': plan.hoursPerDay,
        'days_per_cycle': plan.daysPerCycle,
        'price': plan.price,
        'currency': plan.currency,
        'badge_text': plan.badgeText,
        'is_featured': plan.isFeatured,
        'active': plan.active,
      };
}
