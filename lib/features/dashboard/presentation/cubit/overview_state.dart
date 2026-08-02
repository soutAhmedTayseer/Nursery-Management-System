/// One recent check-in/check-out for the Live Activity Feed. Fake data never
/// checks a kid back out, so today this is always a check-in — the flag is
/// here so the feed is correct once checkout data exists.
class ActivityEvent {
  const ActivityEvent({required this.kidName, required this.isCheckIn, required this.at});

  final String kidName;
  final bool isCheckIn;
  final DateTime at;
}

abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  OverviewLoaded({
    required this.checkedInCount,
    required this.totalRoster,
    required this.totalHoursToday,
    required this.recentEvents,
  });

  final int checkedInCount;
  final int totalRoster;
  final double totalHoursToday;
  final List<ActivityEvent> recentEvents;

  double get occupancyFraction => totalRoster == 0 ? 0 : (checkedInCount / totalRoster).clamp(0, 1);
}
