import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit(this._sessionsRepository, this._dashboardRepository)
      : super(OverviewInitial());

  final SessionsRepository _sessionsRepository;
  final DashboardRepository _dashboardRepository;

  Future<void> fetchDashboardData() async {
    emit(OverviewLoading());
    try {
      // Occupancy and the rest of the tiles come from one dashboard call now,
      // rather than paging the entire roster to count it client-side.
      final stats = await _dashboardRepository.fetchStats();

      // Hours-on-site is still summed from the roster: it is elapsed time for
      // kids currently in, which the dashboard endpoint does not carry.
      final result = await _sessionsRepository.fetchKidSessions(
        page: 1,
        pageSize: 1000,
      );
      var totalHoursToday = 0.0;
      for (final kidSession in result.items) {
        if (!kidSession.isCheckedIn) continue;
        totalHoursToday += (kidSession.elapsed?.inMinutes ?? 0) / 60;
      }

      emit(OverviewLoaded(
        checkedInCount: stats.occupancy,
        totalHoursToday: totalHoursToday,
        stats: stats,
      ));
    } on ApiException catch (exception) {
      emit(OverviewError(exception));
    }
  }
}
