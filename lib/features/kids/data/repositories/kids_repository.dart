import 'package:nursery_shared/nursery_shared.dart';

/// Kid records and their enrollment lifecycle (contract §4 "Kids").
///
/// Implementations throw [ApiException] on failure — nothing else. The
/// lifecycle methods return the updated [Kid] so callers refresh from the
/// response instead of refetching.
abstract class KidsRepository {
  /// One page of kids, newest filter applied server-side. [page] is 1-based.
  /// [status] narrows by enrollment state; null means all.
  Future<PaginatedResult<Kid>> fetchKids({
    int page = 1,
    int pageSize = 20,
    KidStatus? status,
    String query = '',
  });

  Future<Kid> fetchKid(String id);

  /// Creates a kid. The server assigns the id and the QR payload — neither is
  /// sent. `photoUrl` is optional: the registration form collects no photo, so
  /// one is attached later with [updateKid].
  Future<Kid> createKid({
    required String fullName,
    required DateTime dateOfBirth,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
  });

  /// Updates the given fields only. Omitted arguments are left untouched.
  Future<Kid> updateKid(
    String id, {
    String? fullName,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  /// Uploads a local file and returns the URL to store as `photo_url`.
  /// Uploading and attaching are separate steps (contract §4 "Uploads").
  Future<String> uploadPhoto(String filePath);

  Future<Kid> approve(String id);
  Future<Kid> reject(String id, {required String reason});
  Future<Kid> waitlist(String id);
  Future<Kid> activate(String id);
  Future<Kid> deactivate(String id);
}
