class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.category,
    required this.hoursIncluded,
    required this.hoursPerDay,
    required this.daysPerCycle,
    required this.price,
    required this.currency,
    required this.badgeText,
    required this.isFeatured,
    required this.active,
  });

  final String id;

  /// The line-item label, e.g. `3 hours / 5 Days`.
  final String name;

  /// Heading this plan sits under, e.g. `Monthly Packages`. The admin catalog
  /// groups plans by exact match on this string; icon and colour for a category
  /// are a client concern, mapped from design tokens (contract §2).
  final String category;

  final double hoursIncluded;

  /// Contracted hours per day. Null means a full-day plan with no hourly cap.
  final double? hoursPerDay;

  final int daysPerCycle;

  /// Numeric, never a formatted string — format it with [currency] at render
  /// time. The old UI carried `"AED 1,200"`, which is a presentation concern.
  final double price;

  final String currency;

  /// Optional pill on the catalog card, e.g. `BEST VALUE`.
  final String? badgeText;

  final bool isFeatured;
  final bool active;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      hoursIncluded: (json['hours_included'] as num).toDouble(),
      hoursPerDay: (json['hours_per_day'] as num?)?.toDouble(),
      daysPerCycle: (json['days_per_cycle'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      badgeText: json['badge_text'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'hours_included': hoursIncluded,
        'hours_per_day': hoursPerDay,
        'days_per_cycle': daysPerCycle,
        'price': price,
        'currency': currency,
        'badge_text': badgeText,
        'is_featured': isFeatured,
        'active': active,
      };
}

/// Which plan a kid is currently on. Assignment is separate from payment —
/// a kid can be assigned and unpaid (contract §4 "Subscriptions").
class PlanAssignmentRecord {
  const PlanAssignmentRecord({
    required this.kidId,
    required this.planId,
    required this.planName,
    required this.planCategory,
    required this.assignedAt,
    required this.assignedBy,
  });

  final String kidId;
  final String planId;
  final String planName;
  final String planCategory;
  final DateTime assignedAt;
  final String assignedBy;

  factory PlanAssignmentRecord.fromJson(Map<String, dynamic> json) {
    return PlanAssignmentRecord(
      kidId: json['kid_id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      planCategory: json['plan_category'] as String? ?? '',
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      assignedBy: json['assigned_by'] as String? ?? '',
    );
  }
}

/// One move between plans. Plan names are denormalized server-side so history
/// still reads correctly after a plan is renamed or deleted.
class PlanChange {
  const PlanChange({
    required this.id,
    required this.kidId,
    required this.oldPlanName,
    required this.newPlanName,
    required this.changedBy,
    required this.changedAt,
  });

  final String id;
  final String kidId;
  final String? oldPlanName;
  final String newPlanName;
  final String changedBy;
  final DateTime changedAt;

  factory PlanChange.fromJson(Map<String, dynamic> json) {
    return PlanChange(
      id: json['id'] as String,
      kidId: json['kid_id'] as String,
      oldPlanName: json['old_plan_name'] as String?,
      newPlanName: json['new_plan_name'] as String,
      changedBy: json['changed_by'] as String? ?? '',
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}
