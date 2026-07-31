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
}
