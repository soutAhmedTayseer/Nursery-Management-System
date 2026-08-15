import 'package:nursery_shared/nursery_shared.dart';

import '../models/kid_session.dart';

/// Reads for the Sessions screen.
///
/// Implementations throw [ApiException] on failure — nothing else. The fake
/// implementation backs the UI today; `ApiSessionsRepository` replaces it at
/// integration by changing one registration line in `core/di/injection.dart`.
/// Narrows the roster to who is currently on site. Applied server-side
/// alongside paging, so a filtered page is still a full page.
enum AttendanceFilter { all, checkedIn, checkedOut }

abstract class SessionsRepository {
  /// One page of kids with their current session state, ordered by name.
  ///
  /// [query] filters on the kid's full name, case-insensitively; [filter]
  /// narrows by checked-in state. [page] is 1-based. Sorting, paging and
  /// filtering all happen server-side in the API implementation, so callers
  /// must not re-sort or re-filter the returned items.
  Future<PaginatedResult<KidSession>> fetchKidSessions({
    required int page,
    required int pageSize,
    String query = '',
    AttendanceFilter filter = AttendanceFilter.all,
  });

  /// Roster-wide checked-in/out counts, independent of the current page or
  /// search filter — backs the Sessions screen's summary pills.
  Future<({int checkedIn, int checkedOut})> fetchAttendanceCounts();

  /// Adds a newly registered kid to the roster, not yet checked in.
  /// [planLabel] is the display name of the plan picked at registration,
  /// e.g. "Monthly Packages · 3 hours / 5 Days".
  ///
  /// A no-op in the API implementation — `POST /kids` already created the kid
  /// and the roster is derived server-side. It stays on the interface because
  /// the fake keeps its own roster list, which would otherwise never see a
  /// newly registered child when the app runs offline.
  Future<void> addKid(Kid kid, {required String planLabel});

  /// Opens a new session for [kidId]. No-op if already checked in.
  Future<KidSession?> checkIn(String kidId);

  /// Closes [kidId]'s open session. No-op if already checked out.
  Future<KidSession?> checkOut(String kidId);

  /// Flips the scanned kid's checked-in state.
  ///
  /// Takes the raw [qrPayload], not a kid id: the payload is signed and
  /// verified server-side (contract §5), so the client cannot decode it, and
  /// the server is also the only party that can decide the direction without
  /// racing a second admin scanning the same child. Returns null for a payload
  /// that matches no kid.
  Future<KidSession?> clockToggle(String qrPayload);

  /// Updates [kidId]'s photo (local file path or URL). No-op if no kid
  /// matches.
  Future<void> updateKidPhoto(String kidId, String photoUrl);
}
