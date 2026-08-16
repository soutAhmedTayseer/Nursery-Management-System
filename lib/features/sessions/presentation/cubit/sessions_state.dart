part of 'sessions_cubit.dart';

abstract class SessionsState {}

class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState {
  SessionsLoaded({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.searchQuery = '',
    this.filter = AttendanceFilter.all,
    this.checkedInCount = 0,
    this.checkedOutCount = 0,
  });

  final List<KidSession> items;
  final int totalCount;
  final String searchQuery;
  final AttendanceFilter filter;
  final int currentPage;
  final int totalPages;
  final int checkedInCount;
  final int checkedOutCount;
}

class SessionsError extends SessionsState {
  SessionsError(this.exception);

  final ApiException exception;
}

/// A single write (clock in/out, QR toggle) was rejected.
///
/// Distinct from [SessionsError], which means the roster itself could not be
/// read and the screen has nothing to show. This one is transient: the cubit
/// emits it and immediately restores the previous state, so the list stays put
/// and the screen reports it as a snackbar rather than replacing the page.
class SessionsActionFailed extends SessionsState {
  SessionsActionFailed(this.exception);

  final ApiException exception;
}
