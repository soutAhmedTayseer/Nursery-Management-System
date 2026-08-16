import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';

/// The overview screen's tiles, in one call (contract §4 "Dashboard").
class DashboardStats {
  const DashboardStats({
    required this.occupancy,
    required this.capacity,
    required this.pendingApprovalsCount,
    required this.pendingSessionRequestsCount,
    required this.revenueMonthToDate,
    required this.totalOutstanding,
    required this.expiringSubscriptionsCount,
    required this.lowBalanceCount,
  });

  /// Kids currently checked in.
  final int occupancy;
  final int capacity;
  final int pendingApprovalsCount;
  final int pendingSessionRequestsCount;
  final double revenueMonthToDate;
  final double totalOutstanding;
  final int expiringSubscriptionsCount;
  final int lowBalanceCount;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        occupancy: (json['occupancy'] as num?)?.toInt() ?? 0,
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        pendingApprovalsCount:
            (json['pending_approvals_count'] as num?)?.toInt() ?? 0,
        pendingSessionRequestsCount:
            (json['pending_session_requests_count'] as num?)?.toInt() ?? 0,
        revenueMonthToDate:
            (json['revenue_month_to_date'] as num?)?.toDouble() ?? 0,
        totalOutstanding: (json['total_outstanding'] as num?)?.toDouble() ?? 0,
        expiringSubscriptionsCount:
            (json['expiring_subscriptions_count'] as num?)?.toInt() ?? 0,
        lowBalanceCount: (json['low_balance_count'] as num?)?.toInt() ?? 0,
      );
}

abstract class DashboardRepository {
  Future<DashboardStats> fetchStats();
}

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._client);

  final ApiClient _client;

  @override
  Future<DashboardStats> fetchStats() async {
    final response =
        await _client.get<Map<String, dynamic>>('/admin/dashboard');
    return DashboardStats.fromJson(response.data!);
  }
}

/// Offline stand-in. Counts the roster the fake sessions repository holds, so
/// the demo dashboard agrees with the demo Sessions screen instead of showing
/// unrelated numbers.
class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({
    required this.sessionsRepository,
    required this.failureSwitch,
  });

  final SessionsRepository sessionsRepository;
  final FakeFailureSwitch failureSwitch;

  @override
  Future<DashboardStats> fetchStats() async {
    failureSwitch.maybeThrow();
    final counts = await sessionsRepository.fetchAttendanceCounts();
    return DashboardStats(
      occupancy: counts.checkedIn,
      capacity: 50,
      pendingApprovalsCount: 0,
      pendingSessionRequestsCount: 0,
      revenueMonthToDate: 0,
      totalOutstanding: 0,
      expiringSubscriptionsCount: 0,
      lowBalanceCount: 0,
    );
  }
}
