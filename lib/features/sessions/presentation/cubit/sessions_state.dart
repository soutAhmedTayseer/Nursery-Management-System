part of 'sessions_cubit.dart';

abstract class SessionsState {}

class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState {
  final List<ChildSessionModel> displayedKids;
  final int totalCount;
  final String searchQuery;
  final int currentPage;
  final int totalPages;

  SessionsLoaded({
    required this.displayedKids,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.searchQuery = "",
  });
}

class SessionsError extends SessionsState {
  final String message;
  SessionsError(this.message);
}
