import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/services/qr_code_service.dart';
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
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    final needle = query.trim().toLowerCase();
    final matches = needle.isEmpty
        ? _seed
        : _seed.where((e) => e.kid.fullName.toLowerCase().contains(needle)).toList(growable: false);

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
  Future<void> addKid(Kid kid) async {
    _seed.add(KidSession(kid: kid, activeSession: null, planLabel: 'Not Assigned Yet'));
  }

  @override
  Future<KidSession?> checkIn(String kidId) async {
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1 || _seed[index].isCheckedIn) return null;
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
  Future<KidSession?> clockToggle(String kidId) async {
    final index = _seed.indexWhere((e) => e.kid.id == kidId);
    if (index == -1) return null;
    return _seed[index].isCheckedIn ? checkOut(kidId) : checkIn(kidId);
  }

  KidSession _withSession(KidSession entry, Session session) =>
      KidSession(kid: entry.kid, activeSession: session, planLabel: entry.planLabel);

  static DateTime get _now => DateTime.now();

  static KidSession _entry(
    String id,
    String name,
    String plan, {
    double? hoursIn,
  }) {
    return KidSession(
      kid: Kid(
        id: id,
        fullName: name,
        dateOfBirth: DateTime(2021, 5, 12),
        photoUrl: '',
        status: KidStatus.active,
        allergies: null,
        medicalNotes: null,
        emergencyContactName: 'Emergency Contact',
        emergencyContactPhone: '+971500000000',
        createdBy: 'admin',
        createdAt: DateTime(2026, 1, 1),
        approvedAt: DateTime(2026, 1, 2),
        approvedBy: 'admin-1',
        qrPayload: QrCodeService.signKidId(id),
      ),
      activeSession: hoursIn == null
          ? null
          : Session(
              id: 'session-$id',
              kidId: id,
              requestedBy: 'guardian',
              requestedById: 'guardian-$id',
              status: SessionStatus.confirmed,
              checkedInAt: _now.subtract(
                Duration(minutes: (hoursIn * 60).round()),
              ),
              confirmedBy: 'admin-1',
              checkedOutAt: null,
              checkedOutConfirmedBy: null,
              hoursDeducted: null,
              subscriptionId: 'sub-$id',
            ),
      planLabel: plan,
    );
  }

  static final List<KidSession> _seed = [
    _entry('1', 'Leo Maxwell', 'Full-time', hoursIn: 3.7),
    _entry('2', 'Amira Khalid', '3 Days/Week'),
    _entry('3', 'Noah James', 'Full-time', hoursIn: 1.25),
    _entry('4', 'Sophie Liam', 'Full-time', hoursIn: 4.83),
    _entry('5', 'Ethan Wright', 'Mornings Only'),
    _entry('6', 'Maya Rose', 'Full-time', hoursIn: 2.17),
    _entry('7', 'Oliver Smith', 'Full-time', hoursIn: 1.0),
    _entry('8', 'Emma Davis', '3 Days/Week'),
    _entry('9', 'Lucas Brown', 'Mornings Only', hoursIn: 2.5),
    _entry('10', 'Mia Wilson', 'Full-time'),
    _entry('11', 'Aiden Taylor', 'Full-time', hoursIn: 4.17),
    _entry('12', 'Isabella Moore', '3 Days/Week'),
  ];
}
