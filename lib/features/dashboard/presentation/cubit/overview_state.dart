abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  OverviewLoaded({
    required this.checkedInCount,
    required this.totalRoster,
    required this.totalHoursToday,
  });

  final int checkedInCount;
  final int totalRoster;
  final double totalHoursToday;

  double get occupancyFraction => totalRoster == 0 ? 0 : (checkedInCount / totalRoster).clamp(0, 1);
}
