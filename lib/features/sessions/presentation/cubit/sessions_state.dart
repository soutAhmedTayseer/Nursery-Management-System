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
  });

  final List<KidSession> items;
  final int totalCount;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
}

class SessionsError extends SessionsState {
  SessionsError(this.exception);

  final ApiException exception;
}
