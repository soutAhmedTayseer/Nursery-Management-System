import 'package:nursery_shared/nursery_shared.dart';

/// Fields the admin app sends when creating or updating a child.
///
/// Mirrors `CreateChildCommand` / `UpdateChildCommand`. `emergencyContacts` is
/// only read on create - on update the API manages them through the dedicated
/// add/remove endpoints.
class ChildInput {
  const ChildInput({
    required this.fullName,
    required this.dateOfBirth,
    required this.enrollmentDate,
    required this.nationality,
    required this.religion,
    required this.homeAddress,
    required this.allergies,
    required this.mother,
    required this.father,
    required this.agreement,
    this.emergencyContacts = const [],
  });

  final String fullName;
  final DateTime dateOfBirth;
  final DateTime enrollmentDate;
  final String nationality;
  final String religion;
  final String homeAddress;
  final String? allergies;
  final ParentContact mother;
  final ParentContact father;
  final ChildAgreement agreement;
  final List<NewEmergencyContact> emergencyContacts;

  Map<String, dynamic> _base() => {
        'fullName': fullName,
        'dateOfBirth': _dateOnly(dateOfBirth),
        'enrollmentDate': _dateOnly(enrollmentDate),
        'nationality': nationality,
        'religion': religion,
        'homeAddress': homeAddress,
        'allergies': allergies,
        'mother': mother.toJson(),
        'father': father.toJson(),
        'agreement': agreement.toJson(),
      };

  Map<String, dynamic> toCreateJson() => {
        ..._base(),
        'emergencyContacts': [
          for (final c in emergencyContacts) c.toJson(),
        ],
      };

  Map<String, dynamic> toUpdateJson() => _base();
}

/// Body for `POST /api/children/{childId}/emergency-contacts` and the inline
/// `emergencyContacts` array on create.
class NewEmergencyContact {
  const NewEmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  final String name;
  final String relationship;
  final String phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'relationship': relationship,
        'phone': phone,
      };
}

String _dateOnly(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Every operation the admin app performs against the live `Admin Children`
/// endpoints. Writes return the refreshed [Child] because the API answers
/// mutations with an empty body.
abstract class ChildrenRepository {
  /// `GET /api/children` - one page of the roster.
  Future<PaginatedResult<ChildSummary>> fetchChildren({
    int page = 1,
    int pageSize = 20,
    String search = '',
    bool activeOnly = false,
  });

  /// `GET /api/children/{id}`.
  Future<Child> fetchChild(String id);

  /// `POST /api/children`. The API returns no id, so this refetches the roster
  /// and returns the newly created row (matched by name + enrolment date).
  Future<ChildSummary?> createChild(ChildInput input);

  /// `PUT /api/children/{id}`.
  Future<Child> updateChild(String id, ChildInput input);

  /// `PUT /api/children/{id}/active` - the quick roster toggle.
  Future<Child> setActive(String id, {required bool isActive});

  /// `PUT /api/children/{id}/status` - the full lifecycle transition.
  Future<Child> setStatus(String id, ChildStatus status);

  /// `POST /api/children/{id}/scan-code/regenerate` - invalidates the old QR.
  Future<Child> regenerateScanCode(String id);

  /// `POST /api/children/{id}/photo` (multipart, field `file`).
  Future<Child> uploadPhoto(String id, String filePath);

  /// `DELETE /api/children/{id}/photo`.
  Future<Child> deletePhoto(String id);

  /// `POST /api/children/{childId}/emergency-contacts`.
  Future<Child> addEmergencyContact(String childId, NewEmergencyContact contact);

  /// `DELETE /api/children/{childId}/emergency-contacts/{contactId}`.
  Future<Child> removeEmergencyContact(String childId, String contactId);
}
