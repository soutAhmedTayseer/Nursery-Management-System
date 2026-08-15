import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import '../models/plan_catalog.dart';
import '../models/subscription_plan.dart';
import 'plans_repository.dart';

/// In-memory [PlansRepository], seeded by flattening [kInitialPlanCategories]
/// back into the wire shape so the offline catalog matches what shipped.
class FakePlansRepository implements PlansRepository {
  FakePlansRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 300),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  late final List<Plan> _plans = [
    for (final category in kInitialPlanCategories)
      for (final item in category.lineItems)
        PlanCatalog.toPlan(
          item,
          category: category.name,
          currency: 'AED',
          isFeatured: category.isFeatured,
        ),
  ];

  final Map<String, PlanAssignmentRecord> _assignments = {};
  final Map<String, List<PlanChange>> _history = {};

  @override
  Future<List<Plan>> fetchPlans() async {
    await _tick();
    return List.unmodifiable(_plans);
  }

  @override
  Future<Plan> createPlan(Plan plan) async {
    await _tick();
    final created = plan.id.isEmpty ? _withId(plan, _newId()) : plan;
    _plans.add(created);
    return created;
  }

  @override
  Future<Plan> updatePlan(Plan plan) async {
    await _tick();
    final index = _indexOf(plan.id);
    _plans[index] = plan;
    return plan;
  }

  @override
  Future<Plan> deactivatePlan(String planId) async {
    await _tick();
    final index = _indexOf(planId);
    final deactivated = _withId(_plans[index], planId, active: false);
    _plans[index] = deactivated;
    return deactivated;
  }

  @override
  Future<PlanAssignmentRecord?> fetchAssignment(String kidId) async {
    await _tick();
    return _assignments[kidId];
  }

  @override
  Future<PlanAssignmentRecord> assignPlan(String kidId, String planId) async {
    await _tick();
    final plan = _plans[_indexOf(planId)];
    final previous = _assignments[kidId];

    final assignment = PlanAssignmentRecord(
      kidId: kidId,
      planId: plan.id,
      planName: plan.name,
      planCategory: plan.category,
      assignedAt: DateTime.now(),
      assignedBy: 'admin',
    );
    _assignments[kidId] = assignment;

    // Mirrors the server appending a PlanChange on every successful assign.
    _history.putIfAbsent(kidId, () => []).insert(
          0,
          PlanChange(
            id: _newId(),
            kidId: kidId,
            oldPlanName: previous?.planName,
            newPlanName: plan.name,
            changedBy: 'admin',
            changedAt: DateTime.now(),
          ),
        );

    return assignment;
  }

  @override
  Future<List<PlanChange>> fetchPlanHistory(String kidId) async {
    await _tick();
    return List.unmodifiable(_history[kidId] ?? const []);
  }

  @override
  Future<Subscription> recordPurchase(
    String kidId, {
    required String planId,
    required String paymentMethod,
    String? notes,
  }) async {
    await _tick();
    final plan = _plans[_indexOf(planId)];
    return Subscription(
      id: _newId(),
      kidId: kidId,
      planId: plan.id,
      hoursRemaining: plan.hoursIncluded,
      hoursTotal: plan.hoursIncluded,
      purchasedAt: DateTime.now(),
      recordedBy: 'admin',
      paymentMethod: paymentMethod,
      notes: notes,
      status: SubscriptionStatus.active,
    );
  }

  Future<void> _tick() async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
  }

  int _indexOf(String planId) {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index == -1) {
      throw const ApiException(
        code: 'PLAN_NOT_FOUND',
        message: 'Plan not found',
        statusCode: 404,
      );
    }
    return index;
  }

  static Plan _withId(Plan plan, String id, {bool? active}) => Plan(
        id: id,
        name: plan.name,
        category: plan.category,
        hoursIncluded: plan.hoursIncluded,
        hoursPerDay: plan.hoursPerDay,
        daysPerCycle: plan.daysPerCycle,
        price: plan.price,
        currency: plan.currency,
        badgeText: plan.badgeText,
        isFeatured: plan.isFeatured,
        active: active ?? plan.active,
      );

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
