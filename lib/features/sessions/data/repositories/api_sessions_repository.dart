import 'package:nursery_shared/nursery_shared.dart';

import '../models/kid_session.dart';
import 'sessions_repository.dart';

/// Backs the Sessions screen off `GET /admin/roster` (contract §4).
///
/// The roster is one call rather than a join over `/kids`,
/// `/kids/{id}/sessions` and `/kids/{id}/subscriptions`: that would cost
/// 1 + N + N requests per page, and the attendance filter and the summary
/// counts still could not be computed, since both describe the whole roster
/// while the client holds one page of it.
class ApiSessionsRepository implements SessionsRepository {
  ApiSessionsRepository(this._client);

  final ApiClient _client;

  /// The counts from the most recent roster read.
  ///
  /// They arrive on the same response as the page, so [fetchAttendanceCounts]
  /// reuses them instead of making a second round-trip. The cubit always calls
  /// it directly after [fetchKidSessions], so it is never stale in practice.
  ({int checkedIn, int checkedOut}) _counts = (checkedIn: 0, checkedOut: 0);

  @override
  Future<PaginatedResult<KidSession>> fetchKidSessions({
    required int page,
    required int pageSize,
    String query = '',
    AttendanceFilter filter = AttendanceFilter.all,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/admin/roster',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (query.trim().isNotEmpty) 'query': query.trim(),
        'attendance': _attendance(filter),
      },
    );
    final body = response.data!;

    _counts = (
      checkedIn: (body['checked_in_count'] as num?)?.toInt() ?? 0,
      checkedOut: (body['checked_out_count'] as num?)?.toInt() ?? 0,
    );

    return PaginatedResult.fromJson(body, _rosterItem);
  }

  @override
  Future<({int checkedIn, int checkedOut})> fetchAttendanceCounts() async => _counts;

  @override
  Future<void> addKid(Kid kid, {required String planLabel}) async {
    // No-op: POST /kids already created them and the roster is server-derived.
    // See SessionsRepository.addKid for why this stays on the interface.
  }

  @override
  Future<KidSession?> checkIn(String kidId) =>
      _toggle('/admin/kids/$kidId/sessions/direct-check-in');

  @override
  Future<KidSession?> checkOut(String kidId) =>
      _toggle('/admin/kids/$kidId/sessions/direct-check-out');

  @override
  Future<KidSession?> clockToggle(String qrPayload) =>
      _toggle('/admin/sessions/qr-toggle', data: {'qr_payload': qrPayload});

  @override
  Future<void> updateKidPhoto(String kidId, String photoUrl) async {
    await _client.patch<Map<String, dynamic>>(
      '/kids/$kidId',
      data: {'photo_url': photoUrl},
    );
  }

  /// Every write returns a roster item, so they all decode the same way.
  /// A 404 means the kid or the scanned code matched nothing — the cubit
  /// renders that as "unrecognized", not as an error.
  Future<KidSession?> _toggle(String path, {Object? data}) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(path, data: data);
      return _rosterItem(response.data!);
    } on ApiException catch (exception) {
      if (exception.statusCode == 404) return null;
      rethrow;
    }
  }

  static KidSession _rosterItem(Map<String, dynamic> json) {
    final session = json['active_session'] as Map<String, dynamic>?;
    return KidSession(
      kid: Kid.fromJson(json['kid'] as Map<String, dynamic>),
      activeSession: session == null ? null : Session.fromJson(session),
      planLabel: json['plan_label'] as String? ?? '',
    );
  }

  static String _attendance(AttendanceFilter filter) => switch (filter) {
        AttendanceFilter.all => 'all',
        AttendanceFilter.checkedIn => 'checked_in',
        AttendanceFilter.checkedOut => 'checked_out',
      };
}
