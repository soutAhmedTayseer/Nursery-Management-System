/// A snapshot of which [PlanCategory]/[PlanLineItem] a kid is currently
/// subscribed to. Denormalized (kid/parent name+phone copied in at
/// assignment time) so Finance/Dashboard can render without depending on
/// SessionsCubit's paginated kid roster — matches this app's no-backend,
/// in-memory-Cubit pattern elsewhere.
class PlanAssignment {
  const PlanAssignment({
    required this.kidId,
    required this.kidName,
    required this.parentName,
    required this.parentPhone,
    required this.categoryId,
    required this.lineItemId,
    required this.assignedAt,
  });

  final String kidId;
  final String kidName;
  final String parentName;
  final String parentPhone;
  final String categoryId;
  final String lineItemId;
  final DateTime assignedAt;
}
