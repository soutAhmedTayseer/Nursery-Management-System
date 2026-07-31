import 'package:nursery_shared/nursery_shared.dart';

/// A kid paired with their currently open session, as the Sessions screen
/// shows them.
///
/// This is a display composite, not a wire model — `GET /admin/sessions`
/// returns sessions and `GET /kids` returns kids, and the API repository joins
/// them. Wire models stay in `nursery_shared` (root AGENTS.md §2).
class KidSession {
  const KidSession({
    required this.kid,
    required this.activeSession,
    required this.planLabel,
  });

  final Kid kid;
  final Session? activeSession;

  /// Display name of the kid's current plan, e.g. "Full-time".
  final String planLabel;

  bool get isCheckedIn =>
      activeSession != null && activeSession!.checkedOutAt == null;

  /// Time since check-in, or null when the kid is not currently in.
  Duration? get elapsed {
    final checkedInAt = activeSession?.checkedInAt;
    if (!isCheckedIn || checkedInAt == null) return null;
    return DateTime.now().difference(checkedInAt);
  }
}
