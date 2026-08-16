import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/kid_session.dart';
import '../../data/repositories/sessions_repository.dart';

part 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repository) : super(SessionsInitial());

  final SessionsRepository _repository;

  static const int _pageSize = 8;

  int get pageSize => _pageSize;

  String _query = '';
  int _page = 1;
  int _requestId = 0;
  AttendanceFilter _filter = AttendanceFilter.all;

  Future<void> loadSessions() => _fetch();

  Future<void> search(String query) {
    _query = query;
    _page = 1; // a new query invalidates the current page
    return _fetch();
  }

  Future<void> setFilter(AttendanceFilter filter) {
    _filter = filter;
    _page = 1; // the filtered roster is a different, shorter list
    return _fetch();
  }

  Future<void> changePage(int page) {
    _page = page;
    return _fetch();
  }

  Future<void> clockIn(String kidId) =>
      _write(() => _repository.checkIn(kidId));

  Future<void> clockOut(String kidId) =>
      _write(() => _repository.checkOut(kidId));

  /// Clocks the scanned kid in or out, whichever is the opposite of their
  /// current state. Returns the kid's display name on success, or null if the
  /// payload matched no kid.
  ///
  /// The payload is passed through untouched — it is signed and verified
  /// server-side (contract §5), so the client neither decodes nor trusts it.
  Future<String?> handleQrScan(String payload) async {
    KidSession? updated;
    final succeeded = await _write(() async {
      updated = await _repository.clockToggle(payload);
    });
    if (!succeeded) return null;
    return updated?.kid.fullName;
  }

  /// Runs a write, then refreshes.
  ///
  /// The write is inside the try: it used to sit outside, so a `409`
  /// (`KID_ALREADY_CHECKED_IN`, `CAPACITY_EXCEEDED`, `KID_NOT_ACTIVE`) escaped
  /// as an unhandled async error and the button silently did nothing.
  ///
  /// A failure emits [SessionsActionFailed] and then puts the previous state
  /// straight back, so the roster stays on screen — one rejected row must not
  /// blank the whole list the way [SessionsError] would.
  ///
  /// Returns whether the write succeeded.
  Future<bool> _write(Future<void> Function() action) async {
    final previous = state;
    try {
      await action();
    } on ApiException catch (exception) {
      emit(SessionsActionFailed(exception));
      if (previous is SessionsLoaded) emit(previous);
      return false;
    }
    await _fetch();
    return true;
  }

  /// Persists a locally-picked photo for [kidId] and refreshes so every
  /// screen backed by this cubit's repository (Sessions grid included)
  /// picks it up.
  Future<void> updateKidPhoto(String kidId, String photoUrl) async {
    await _repository.updateKidPhoto(kidId, photoUrl);
    await _fetch();
  }

  Future<void> _fetch() async {
    final requestId = ++_requestId;
    emit(SessionsLoading());
    try {
      final result = await _repository.fetchKidSessions(
        page: _page,
        pageSize: _pageSize,
        query: _query,
        filter: _filter,
      );
      final counts = await _repository.fetchAttendanceCounts();
      if (requestId != _requestId) return; // a newer request superseded this one
      emit(SessionsLoaded(
        items: result.items,
        totalCount: result.total,
        currentPage: result.page,
        totalPages: result.totalPages,
        searchQuery: _query,
        filter: _filter,
        checkedInCount: counts.checkedIn,
        checkedOutCount: counts.checkedOut,
      ));
    } on ApiException catch (exception) {
      if (requestId != _requestId) return; // a newer request superseded this one
      emit(SessionsError(exception));
    }
  }
}
