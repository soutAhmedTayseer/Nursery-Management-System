import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Plan round-trips JSON', () {
    final json = {
      'id': 'p1',
      'name': '3 hours / 5 Days',
      'category': 'Monthly Packages',
      'hours_included': 40.0,
      'hours_per_day': 3.0,
      'days_per_cycle': 5,
      'price': 800.0,
      'currency': 'EGP',
      'badge_text': 'BEST VALUE',
      'is_featured': true,
      'active': true,
    };

    final plan = Plan.fromJson(json);

    expect(plan.hoursIncluded, 40.0);
    expect(plan.category, 'Monthly Packages');
    // Numeric on the wire — formatting is the client's job.
    expect(plan.price, 800.0);
    expect(plan.toJson(), json);
  });

  test('Plan treats a full-day plan as having no hourly cap', () {
    final plan = Plan.fromJson({
      'id': 'p2',
      'name': 'Full Day',
      'category': 'Daily',
      'hours_included': 200.0,
      'hours_per_day': null,
      'days_per_cycle': 20,
      'price': 3000.0,
      'currency': 'AED',
      'badge_text': null,
      'is_featured': false,
      'active': true,
    });

    expect(plan.hoursPerDay, isNull);
    expect(plan.badgeText, isNull);
  });

  test('PlanChange keeps the old plan name after the plan itself changes', () {
    final change = PlanChange.fromJson({
      'id': 'pch_01',
      'kid_id': 'kid_01',
      'old_plan_id': 'pln_00',
      'old_plan_name': '2 hours / 3 Days',
      'new_plan_id': 'pln_01',
      'new_plan_name': '3 hours / 5 Days',
      'changed_by': 'adm_01',
      'changed_at': '2026-08-01T07:15:00.000Z',
    });

    expect(change.oldPlanName, '2 hours / 3 Days');
    expect(change.newPlanName, '3 hours / 5 Days');
  });

  test('PlanChange allows a null old plan for a first assignment', () {
    final change = PlanChange.fromJson({
      'id': 'pch_00',
      'kid_id': 'kid_01',
      'old_plan_id': null,
      'old_plan_name': null,
      'new_plan_id': 'pln_01',
      'new_plan_name': '3 hours / 5 Days',
      'changed_by': 'adm_01',
      'changed_at': '2026-07-01T07:15:00.000Z',
    });

    expect(change.oldPlanName, isNull);
  });

  test('PlanAssignmentRecord decodes an assignment', () {
    final assignment = PlanAssignmentRecord.fromJson({
      'kid_id': 'kid_01',
      'plan_id': 'pln_01',
      'plan_name': '3 hours / 5 Days',
      'plan_category': 'Monthly Packages',
      'assigned_at': '2026-08-01T07:15:00.000Z',
      'assigned_by': 'adm_01',
    });

    expect(assignment.planName, '3 hours / 5 Days');
    expect(assignment.planCategory, 'Monthly Packages');
  });
}
