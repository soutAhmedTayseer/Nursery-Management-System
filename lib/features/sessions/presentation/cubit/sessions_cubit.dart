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

  Future<void> loadSessions() => _fetch();

  Future<void> search(String query) {
    _query = query;
    _page = 1; // a new query invalidates the current page
    return _fetch();
  }

  Future<void> changePage(int page) {
    _page = page;
    return _fetch();
  }

  Future<void> _fetch() async {
    final requestId = ++_requestId;
    emit(SessionsLoading());
    try {
      final result = await _repository.fetchKidSessions(
        page: _page,
        pageSize: _pageSize,
        query: _query,
      );
      if (requestId != _requestId) return; // a newer request superseded this one
      emit(SessionsLoaded(
        items: result.items,
        totalCount: result.total,
        currentPage: result.page,
        totalPages: result.totalPages,
        searchQuery: _query,
      ));
    } on ApiException catch (exception) {
      if (requestId != _requestId) return; // a newer request superseded this one
      emit(SessionsError(exception));
    }
  }
}
