abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  OverviewLoaded({required this.checkedInCount, required this.totalHoursToday});

  final int checkedInCount;
  final double totalHoursToday;
}
