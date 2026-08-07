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
