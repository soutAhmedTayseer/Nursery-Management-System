import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/services/qr_code_service.dart';
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

  Future<void> clockIn(String kidId) async {
    await _repository.checkIn(kidId);
    await _fetch();
  }

  Future<void> clockOut(String kidId) async {
    await _repository.checkOut(kidId);
    await _fetch();
  }

  /// Decodes a scanned QR payload and clocks that kid in or out, whichever
  /// is the opposite of their current state. Returns the kid's display name
  /// on success, or null if the payload didn't verify or matched no kid.
  Future<String?> handleQrScan(String payload) async {
    final kidId = QrCodeService.verify(payload);
    if (kidId == null) return null;
    final updated = await _repository.clockToggle(kidId);
    if (updated == null) return null;
    await _fetch();
    return updated.kid.fullName;
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
