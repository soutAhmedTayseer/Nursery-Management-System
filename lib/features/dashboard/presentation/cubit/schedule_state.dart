import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/schedule_item.dart';

class ScheduleState {
  const ScheduleState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ScheduleItemModel> items;
  final bool isLoading;

  /// Set when a read or write failed. The routine is shared across admins now,
  /// so an edit that silently did not save would leave two admins looking at
  /// different timetables.
  final ApiException? error;

  ScheduleState copyWith({
    List<ScheduleItemModel>? items,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) =>
      ScheduleState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}
