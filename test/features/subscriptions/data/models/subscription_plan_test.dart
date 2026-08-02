import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/subscriptions/data/models/subscription_plan.dart';

void main() {
  test('PlanLineItem carries label, price and optional badge', () {
    const item = PlanLineItem(id: 'li1', label: '3 hours / 3 Days', price: '600 AED');
    expect(item.label, '3 hours / 3 Days');
    expect(item.price, '600 AED');
    expect(item.badgeText, isNull);
  });

  test('PlanCategory groups line items and defaults isFeatured to false', () {
    const category = PlanCategory(
      id: 'cat1',
      name: 'Monthly Packages',
      icon: Icons.calendar_month,
      themeColor: Colors.green,
      lineItems: [PlanLineItem(id: 'li1', label: 'One Hour', price: '35 AED')],
    );
    expect(category.isFeatured, isFalse);
    expect(category.lineItems, hasLength(1));
  });

  test('kInitialPlanCategories seeds the three Figma categories', () {
    expect(kInitialPlanCategories, hasLength(3));
    expect(kInitialPlanCategories.map((c) => c.name), containsAll([
      'Monthly Packages',
      'Daily Subscription',
      'Weekly Special Offers',
    ]));
    final featured = kInitialPlanCategories.where((c) => c.isFeatured);
    expect(featured, hasLength(1));
    expect(featured.first.name, 'Weekly Special Offers');
  });
}
