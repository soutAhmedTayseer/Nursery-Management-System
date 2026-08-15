import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/services/qr_code_service.dart';
import '../../../../core/testing/attendance_store.dart';
import '../../../../core/testing/demo_photo_store.dart';
import '../../../../core/testing/demo_seed.dart';
import '../../../../core/testing/fake_failure_switch.dart';
import '../models/kid_session.dart';
import 'sessions_repository.dart';

/// In-memory [SessionsRepository] carrying the seed data that used to live
/// inside `SessionsCubit`.
///
/// Filters and slices exactly as the server will, so cubit pagination logic is
/// already correct when this is swapped out. Mutable (not `static final`) —
/// registration and clock-in/out write through here so every screen backed
/// by this repository stays in sync.
class FakeSessionsRepository implements SessionsRepository {
  FakeSessionsRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 400),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  @override
  Future<PaginatedResult<KidSession>> fetchKidSessions({
    required int page,
    required int pageSize,
    String query = '',
    AttendanceFilter filter = AttendanceFilter.all,
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    final needle = query.trim().toLowerCase();
    final matches = _seed.where((e) {
      final matchesQuery = needle.isEmpty || e.kid.fullName.toLowerCase().contains(needle);
      final matchesFilter = switch (filter) {
        AttendanceFilter.all => true,
        AttendanceFilter.checkedIn => e.isCheckedIn,
        AttendanceFilter.checkedOut => !e.isCheckedIn,
      };
      return matchesQuery && matchesFilter;
    }).toList()
      // Alphabetical so a child sits in the same place every visit, instead
      // of wherever they happen to fall in insertion order.
      ..sort((a, b) => a.kid.fullName.toLowerCase().compareTo(b.kid.fullName.toLowerCase()));

    final start = (page - 1) * pageSize;
    final items = start >= matches.length
        ? const <KidSession>[]
        : matches.skip(start).take(pageSize).toList(growable: false);

    return PaginatedResult<KidSession>(
      items: items,
      total: matches.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<({int checkedIn, int checkedOut})> fetchAttendanceCounts() async {
    final checkedIn = _seed.where((e) => e.isCheckedIn).length;
    return (checkedIn: checkedIn, checkedOut: _seed.length - checkedIn);
  }

  @override
  Future<void> addKid(Kid kid, {required String planLabel}) async {
    _seed.add(KidSession(kid: kid, activeSession: null, planLabel: planLabel));
  }

  @override
  Future<KidSession?> checkIn(String kidId) async {
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1 || _seed[index].isCheckedIn) return null;
    // Mirror into the attendance ledger so the child's calendar, their
    // overtime, and the dashboard's per-day figures all reflect this
    // clock-in immediately.
    AttendanceStore.instance.checkIn(kidId, _now);
    final updated = _withSession(
      _seed[index],
      Session(
        id: 'session-$kidId-${_now.millisecondsSinceEpoch}',
        kidId: kidId,
        requestedBy: 'admin',
        requestedById: 'admin-1',
        status: SessionStatus.confirmed,
        checkedInAt: _now,
        confirmedBy: 'admin-1',
        checkedOutAt: null,
        checkedOutConfirmedBy: null,
        hoursDeducted: null,
        subscriptionId: null,
      ),
    );
    _seed[index] = updated;
    return updated;
  }

  @override
  Future<KidSession?> checkOut(String kidId) async {
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1 || !_seed[index].isCheckedIn) return null;
    AttendanceStore.instance.checkOut(kidId, _now);
    final session = _seed[index].activeSession!;
    final updated = _withSession(
      _seed[index],
      Session(
        id: session.id,
        kidId: session.kidId,
        requestedBy: session.requestedBy,
        requestedById: session.requestedById,
        status: session.status,
        checkedInAt: session.checkedInAt,
        confirmedBy: session.confirmedBy,
        checkedOutAt: _now,
        checkedOutConfirmedBy: 'admin-1',
        hoursDeducted: session.hoursDeducted,
        subscriptionId: session.subscriptionId,
      ),
    );
    _seed[index] = updated;
    return updated;
  }

  @override
  Future<KidSession?> clockToggle(String qrPayload) async {
    // Offline stand-in for the server validating the payload. The real codes
    // are signed and verified server-side (contract §5); these only have to be
    // scannable without a backend.
    final kidId = QrCodeService.verify(qrPayload);
    if (kidId == null) return null;
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1) return null;
    return _seed[index].isCheckedIn ? checkOut(kidId) : checkIn(kidId);
  }

  @override
  Future<void> updateKidPhoto(String kidId, String photoUrl) async {
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1) return;
    final entry = _seed[index];
    _seed[index] = KidSession(kid: entry.kid.copyWith(photoUrl: photoUrl), activeSession: entry.activeSession, planLabel: entry.planLabel);
    // Written to disk so the photo is still there next launch — see
    // DemoPhotoStore for why this one thing outlives the in-memory demo.
    await DemoPhotoStore.save(kidId, photoUrl);
  }

  KidSession _withSession(KidSession entry, Session session) =>
      KidSession(kid: entry.kid, activeSession: session, planLabel: entry.planLabel);

  static DateTime get _now => DateTime.now();

  /// Shared demo roster — same children (same ids) that PlanAssignmentsCubit
  /// seeds, so Sessions and Finance agree on who's enrolled.
  static final List<KidSession> _seed = [
    for (final child in kDemoChildren) child.toSession(),
  ];
}
