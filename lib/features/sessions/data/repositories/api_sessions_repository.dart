import 'package:nursery_shared/nursery_shared.dart';

import '../../../children/data/repositories/children_repository.dart';
import '../models/kid_session.dart';
import 'sessions_repository.dart';

/// Bridges the Sessions screen to the live `GET /api/children` roster.
///
/// Only the **listing** is live. Check-in/out and the QR clock flow are
/// Phase 2 (`/api/attendance/*`) — those methods are inert here so the grid
/// still renders. `activeSession` is always null, so every child shows as
/// "not checked in" until attendance is wired.
class ApiSessionsRepository implements SessionsRepository {
  ApiSessionsRepository(this._children);

  final ChildrenRepository _children;

  @override
  Future<PaginatedResult<KidSession>> fetchKidSessions({
    required int page,
    required int pageSize,
    String query = '',
    AttendanceFilter filter = AttendanceFilter.all,
  }) async {
    final result = await _children.fetchChildren(
      page: page,
      pageSize: pageSize,
      search: query,
      // The other filters are attendance-state, which we don't have yet.
      activeOnly: false,
    );
    return PaginatedResult<KidSession>(
      items: [for (final c in result.items) _toKidSession(c)],
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
      totalPages: result.totalPages,
    );
  }

  @override
  Future<({int checkedIn, int checkedOut})> fetchAttendanceCounts() async {
    // No attendance endpoint yet; the summary pills read zero until Phase 2.
    return (checkedIn: 0, checkedOut: 0);
  }

  @override
  Future<void> addKid(Kid kid, {required String planLabel}) async {
    // Registration now creates children through POST /api/children directly.
  }

  @override
  Future<KidSession?> checkIn(String kidId) async => null;

  @override
  Future<KidSession?> checkOut(String kidId) async => null;

  @override
  Future<KidSession?> clockToggle(String kidId) async => null;

  @override
  Future<void> updateKidPhoto(String kidId, String photoUrl) async {
    // The Sessions grid photo picker hands us a local file path.
    await _children.uploadPhoto(kidId, photoUrl);
  }
}

KidSession _toKidSession(ChildSummary c) => KidSession(
      kid: Kid(
        id: c.id,
        fullName: c.fullName,
        dateOfBirth: c.dateOfBirth ?? DateTime.now(),
        photoUrl: c.photoUrl,
        status: _toKidStatus(c.status),
        allergies: c.allergies,
        medicalNotes: null,
        emergencyContactName: '',
        emergencyContactPhone: '',
        createdBy: 'admin',
        createdAt: c.createdAt ?? DateTime.now(),
        approvedAt: null,
        approvedBy: null,
        // The QR renders the server-issued scan code verbatim.
        qrPayload: c.scanCode.isEmpty ? null : c.scanCode,
        nationality: c.nationality,
        religion: c.religion,
        homeAddress: c.homeAddress,
      ),
      activeSession: null,
      planLabel: c.currentPlan?.planName ?? '—',
    );

KidStatus _toKidStatus(ChildStatus status) => switch (status) {
      ChildStatus.active => KidStatus.active,
      ChildStatus.inactive => KidStatus.inactive,
      ChildStatus.pending => KidStatus.pendingApproval,
      ChildStatus.rejected => KidStatus.inactive,
    };
