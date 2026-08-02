import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sessions/data/repositories/sessions_repository.dart';
import 'overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit(this._sessionsRepository) : super(OverviewInitial());

  final SessionsRepository _sessionsRepository;

  Future<void> fetchDashboardData() async {
    emit(OverviewLoading());
    // No "today's occupancy summary" endpoint yet — pull the whole roster in
    // one page. Fine at this app's scale; a real backend would expose a
    // dedicated summary instead of paging through everyone.
    final result = await _sessionsRepository.fetchKidSessions(
      page: 1,
      pageSize: 1000,
    );

    var checkedInCount = 0;
    var totalHoursToday = 0.0;
    for (final kidSession in result.items) {
      if (!kidSession.isCheckedIn) continue;
      checkedInCount++;
      totalHoursToday += (kidSession.elapsed?.inMinutes ?? 0) / 60;
    }

    emit(
      OverviewLoaded(
        checkedInCount: checkedInCount,
        totalHoursToday: totalHoursToday,
      ),
    );
  }
}
