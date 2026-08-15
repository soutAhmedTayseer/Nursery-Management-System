import 'package:nursery_shared/nursery_shared.dart';

/// The plan catalog and per-kid plan assignment (contract §4 "Plans" and
/// "Subscriptions").
///
/// Assignment is deliberately separate from purchase: this nursery puts a child
/// on a plan and takes payment as its own step, so [assignPlan] moves no money.
/// Paying is [recordPurchase], which is what tops up hours.
abstract class PlansRepository {
  /// The whole catalog. Grouped into categories by the client, since icon and
  /// colour for a category are design tokens, not server data.
  Future<List<Plan>> fetchPlans();

  Future<Plan> createPlan(Plan plan);
  Future<Plan> updatePlan(Plan plan);

  /// Deactivates rather than deletes — plans are referenced by past
  /// subscriptions and history, so they cannot simply disappear.
  Future<Plan> deactivatePlan(String planId);

  /// The kid's current plan, or null when they have none.
  Future<PlanAssignmentRecord?> fetchAssignment(String kidId);

  /// Assigns without recording payment. Appends a [PlanChange].
  Future<PlanAssignmentRecord> assignPlan(String kidId, String planId);

  Future<List<PlanChange>> fetchPlanHistory(String kidId);

  /// Records a cash/transfer purchase, creating or topping up a subscription.
  Future<Subscription> recordPurchase(
    String kidId, {
    required String planId,
    required String paymentMethod,
    String? notes,
  });
}
