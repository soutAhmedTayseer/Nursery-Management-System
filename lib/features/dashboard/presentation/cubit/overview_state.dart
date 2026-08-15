import 'package:nursery_shared/nursery_shared.dart';

import '../../data/repositories/dashboard_repository.dart';

abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  OverviewLoaded({
    required this.checkedInCount,
    required this.totalHoursToday,
    required this.stats,
  });

  final int checkedInCount;
  final double totalHoursToday;

  /// The rest of the dashboard tiles, straight from `GET /admin/dashboard`.
  final DashboardStats stats;
}

class OverviewError extends OverviewState {
  OverviewError(this.exception);

  final ApiException exception;
}
