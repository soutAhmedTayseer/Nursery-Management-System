import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/services/qr_code_service.dart';
import '../../../../core/testing/demo_seed.dart';
import '../../../../core/testing/fake_failure_switch.dart';
import 'kids_repository.dart';

/// In-memory [KidsRepository] seeded from [kDemoChildren], so the offline path
/// keeps the roster the app has always shown.
///
/// Filters, sorts and pages exactly as the server does, so cubit paging logic
/// is already correct when this is swapped out.
class FakeKidsRepository implements KidsRepository {
  FakeKidsRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 400),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  late final List<Kid> _kids = kDemoChildren.map((c) => c.kid).toList();

  @override
  Future<PaginatedResult<Kid>> fetchKids({
    int page = 1,
    int pageSize = 20,
    KidStatus? status,
    String query = '',
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    final needle = query.trim().toLowerCase();
    final matches = _kids.where((k) {
      final matchesQuery = needle.isEmpty || k.fullName.toLowerCase().contains(needle);
      return matchesQuery && (status == null || k.status == status);
    }).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    final start = (page - 1) * pageSize;
    final items = start >= matches.length
        ? <Kid>[]
        : matches.sublist(start, (start + pageSize).clamp(0, matches.length));

    return PaginatedResult(items: items, total: matches.length, page: page, pageSize: pageSize);
  }

  @override
  Future<Kid> fetchKid(String id) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
    return _require(id);
  }

  @override
  Future<Kid> createKid({
    required String fullName,
    required DateTime dateOfBirth,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    // Stands in for the server assigning both. The real QR payload is signed
    // server-side (contract §5); this one only has to be scannable offline.
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final kid = Kid(
      id: id,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl ?? '',
      status: KidStatus.active,
      allergies: allergies,
      medicalNotes: medicalNotes,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      createdBy: 'admin',
      createdAt: DateTime.now(),
      approvedAt: DateTime.now(),
      approvedBy: 'admin',
      qrPayload: QrCodeService.signKidId(id),
    );
    _kids.add(kid);
    return kid;
  }

  @override
  Future<Kid> updateKid(
    String id, {
    String? fullName,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    final existing = _require(id);
    // Only photoUrl is editable through the UI today; the rest are accepted so
    // the fake honours the same contract as the API implementation.
    final updated = existing.copyWith(photoUrl: photoUrl);
    _kids[_kids.indexWhere((k) => k.id == id)] = updated;
    return updated;
  }

  @override
  Future<String> uploadPhoto(String filePath) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
    // No storage offline — the local path stands in for the uploaded URL.
    return filePath;
  }

  @override
  Future<Kid> approve(String id) => _setStatus(id, KidStatus.active);

  @override
  Future<Kid> reject(String id, {required String reason}) =>
      _setStatus(id, KidStatus.inactive);

  @override
  Future<Kid> waitlist(String id) => _setStatus(id, KidStatus.waitlisted);

  @override
  Future<Kid> activate(String id) => _setStatus(id, KidStatus.active);

  @override
  Future<Kid> deactivate(String id) => _setStatus(id, KidStatus.inactive);

  Future<Kid> _setStatus(String id, KidStatus status) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();

    final existing = _require(id);
    final updated = Kid(
      id: existing.id,
      fullName: existing.fullName,
      dateOfBirth: existing.dateOfBirth,
      photoUrl: existing.photoUrl,
      status: status,
      allergies: existing.allergies,
      medicalNotes: existing.medicalNotes,
      emergencyContactName: existing.emergencyContactName,
      emergencyContactPhone: existing.emergencyContactPhone,
      createdBy: existing.createdBy,
      createdAt: existing.createdAt,
      approvedAt: existing.approvedAt,
      approvedBy: existing.approvedBy,
      qrPayload: existing.qrPayload,
    );
    _kids[_kids.indexWhere((k) => k.id == id)] = updated;
    return updated;
  }

  Kid _require(String id) {
    final index = _kids.indexWhere((k) => k.id == id);
    if (index == -1) {
      throw const ApiException(
        code: 'KID_NOT_FOUND',
        message: 'Kid not found',
        statusCode: 404,
      );
    }
    return _kids[index];
  }
}
