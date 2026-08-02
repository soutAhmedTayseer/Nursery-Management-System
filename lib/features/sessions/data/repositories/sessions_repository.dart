import 'package:nursery_shared/nursery_shared.dart';

import '../models/kid_session.dart';

/// Reads for the Sessions screen.
///
/// Implementations throw [ApiException] on failure — nothing else. The fake
/// implementation backs the UI today; `ApiSessionsRepository` replaces it at
/// integration by changing one registration line in `core/di/injection.dart`.
abstract class SessionsRepository {
  /// One page of kids with their current session state.
  ///
  /// [query] filters on the kid's full name, case-insensitively. [page] is
  /// 1-based. Paging and filtering happen server-side in the API
  /// implementation, so callers must not re-filter the returned items.
  Future<PaginatedResult<KidSession>> fetchKidSessions({
    required int page,
    required int pageSize,
    String query = '',
  });

  /// Roster-wide checked-in/out counts, independent of the current page or
  /// search filter — backs the Sessions screen's summary pills.
  Future<({int checkedIn, int checkedOut})> fetchAttendanceCounts();

  /// Adds a newly registered kid to the roster, not yet checked in.
  /// [planLabel] is the display name of the plan picked at registration,
  /// e.g. "Monthly Packages · 3 hours / 5 Days".
  Future<void> addKid(Kid kid, {required String planLabel});

  /// Opens a new session for [kidId]. No-op if already checked in.
  Future<KidSession?> checkIn(String kidId);

  /// Closes [kidId]'s open session. No-op if already checked out.
  Future<KidSession?> checkOut(String kidId);

  /// Flips [kidId]'s current checked-in state — used by the QR scan flow,
  /// which only knows a kid id, not their current state. Returns null if no
  /// kid matches [kidId] (a malformed/unrecognized scan).
  Future<KidSession?> clockToggle(String kidId);
}
