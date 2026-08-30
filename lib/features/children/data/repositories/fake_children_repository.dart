import 'package:nursery_shared/nursery_shared.dart';

import 'children_repository.dart';

/// In-memory [ChildrenRepository] for the demo build and widget tests. Keeps
/// the same return contract as the API impl (writes echo the refreshed child).
class FakeChildrenRepository implements ChildrenRepository {
  FakeChildrenRepository() {
    _children[_seed.id] = _seed;
  }

  final Map<String, Child> _children = {};
  int _scanSeq = 0;
  int _contactSeq = 0;

  static final Child _seed = Child(
    id: 'child-1',
    fullName: 'Lina Hassan',
    dateOfBirth: DateTime(2022, 1, 15),
    enrollmentDate: DateTime(2026, 8, 1),
    nationality: 'Egyptian',
    religion: 'Muslim',
    homeAddress: 'Cairo',
    allergies: 'Peanuts',
    photoUrl: '',
    scanCode: 'SCAN-SEED-0001',
    isActive: true,
    approvalStatus: 'Approved',
    status: ChildStatus.active,
    createdAt: DateTime(2026, 8, 1),
    createdBy: 'admin',
    approvedAt: DateTime(2026, 8, 2),
    approvedBy: 'super',
    mother: const ParentContact(
      fullName: 'Mona Ali',
      phone: '+201000000001',
      email: 'mona@example.com',
      occupation: '',
      jobTitle: '',
      companyName: '',
      workPhone: '',
      address: 'Cairo',
    ),
    father: null,
    agreement: ChildAgreement(
      mediaPermission: true,
      parentSignature: 'Mona Ali',
      signedDate: DateTime(2026, 8, 1),
      acceptedTerms: true,
    ),
    emergencyContacts: const [
      ChildEmergencyContact(
        id: 'ec-1',
        name: 'Grandma',
        relationship: 'Relative',
        phone: '+201000000003',
      ),
    ],
    currentPlan: null,
  );

  Child _require(String id) {
    final child = _children[id];
    if (child == null) {
      throw ApiException(
        code: 'NOT_FOUND',
        message: 'No child $id',
        statusCode: 404,
      );
    }
    return child;
  }

  ChildSummary _summary(Child c) => ChildSummary(
        id: c.id,
        fullName: c.fullName,
        dateOfBirth: c.dateOfBirth,
        enrollmentDate: c.enrollmentDate,
        nationality: c.nationality,
        religion: c.religion,
        homeAddress: c.homeAddress,
        allergies: c.allergies,
        photoUrl: c.photoUrl,
        scanCode: c.scanCode,
        isActive: c.isActive,
        approvalStatus: c.approvalStatus,
        status: c.status,
        createdAt: c.createdAt,
        currentPlan: c.currentPlan,
      );

  Child _replace(Child c) {
    _children[c.id] = c;
    return c;
  }

  @override
  Future<PaginatedResult<ChildSummary>> fetchChildren({
    int page = 1,
    int pageSize = 20,
    String search = '',
    bool activeOnly = false,
  }) async {
    final rows = _children.values
        .where((c) => !activeOnly || c.isActive)
        .where((c) =>
            search.isEmpty ||
            c.fullName.toLowerCase().contains(search.toLowerCase()))
        .map(_summary)
        .toList();
    return PaginatedResult<ChildSummary>(
      items: rows,
      total: rows.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Child> fetchChild(String id) async => _require(id);

  @override
  Future<ChildSummary?> createChild(ChildInput input) async {
    final id = 'child-${_children.length + 1}';
    final child = Child(
      id: id,
      fullName: input.fullName,
      dateOfBirth: input.dateOfBirth,
      enrollmentDate: input.enrollmentDate,
      nationality: input.nationality,
      religion: input.religion,
      homeAddress: input.homeAddress,
      allergies: input.allergies,
      photoUrl: '',
      scanCode: 'SCAN-${id.toUpperCase()}',
      isActive: false,
      approvalStatus: 'Pending',
      status: ChildStatus.pending,
      createdAt: DateTime.now(),
      createdBy: 'admin',
      approvedAt: null,
      approvedBy: null,
      mother: input.mother,
      father: input.father,
      agreement: input.agreement,
      emergencyContacts: [
        for (var i = 0; i < input.emergencyContacts.length; i++)
          ChildEmergencyContact(
            id: 'ec-new-${_contactSeq++}',
            name: input.emergencyContacts[i].name,
            relationship: input.emergencyContacts[i].relationship,
            phone: input.emergencyContacts[i].phone,
          ),
      ],
      currentPlan: null,
    );
    return _summary(_replace(child));
  }

  @override
  Future<Child> updateChild(String id, ChildInput input) async {
    final c = _require(id);
    return _replace(Child(
      id: c.id,
      fullName: input.fullName,
      dateOfBirth: input.dateOfBirth,
      enrollmentDate: input.enrollmentDate,
      nationality: input.nationality,
      religion: input.religion,
      homeAddress: input.homeAddress,
      allergies: input.allergies,
      photoUrl: c.photoUrl,
      scanCode: c.scanCode,
      isActive: c.isActive,
      approvalStatus: c.approvalStatus,
      status: c.status,
      createdAt: c.createdAt,
      createdBy: c.createdBy,
      approvedAt: c.approvedAt,
      approvedBy: c.approvedBy,
      mother: input.mother,
      father: input.father,
      agreement: input.agreement,
      emergencyContacts: c.emergencyContacts,
      currentPlan: c.currentPlan,
    ));
  }

  @override
  Future<Child> setActive(String id, {required bool isActive}) async {
    final c = _require(id);
    return _replace(_copy(c, isActive: isActive));
  }

  @override
  Future<Child> setStatus(String id, ChildStatus status) async {
    final c = _require(id);
    return _replace(_copy(c, status: status));
  }

  @override
  Future<Child> regenerateScanCode(String id) async {
    final c = _require(id);
    return _replace(_copy(c, scanCode: 'SCAN-REGEN-${_scanSeq++}'));
  }

  @override
  Future<Child> uploadPhoto(String id, String filePath) async {
    final c = _require(id);
    return _replace(_copy(c, photoUrl: filePath));
  }

  @override
  Future<Child> deletePhoto(String id) async {
    final c = _require(id);
    return _replace(_copy(c, photoUrl: ''));
  }

  @override
  Future<Child> addEmergencyContact(
    String childId,
    NewEmergencyContact contact,
  ) async {
    final c = _require(childId);
    return _replace(_copy(c, emergencyContacts: [
      ...c.emergencyContacts,
      ChildEmergencyContact(
        id: 'ec-new-${_contactSeq++}',
        name: contact.name,
        relationship: contact.relationship,
        phone: contact.phone,
      ),
    ]));
  }

  @override
  Future<Child> removeEmergencyContact(String childId, String contactId) async {
    final c = _require(childId);
    return _replace(_copy(c,
        emergencyContacts:
            c.emergencyContacts.where((e) => e.id != contactId).toList()));
  }

  Child _copy(
    Child c, {
    bool? isActive,
    ChildStatus? status,
    String? scanCode,
    String? photoUrl,
    List<ChildEmergencyContact>? emergencyContacts,
  }) =>
      Child(
        id: c.id,
        fullName: c.fullName,
        dateOfBirth: c.dateOfBirth,
        enrollmentDate: c.enrollmentDate,
        nationality: c.nationality,
        religion: c.religion,
        homeAddress: c.homeAddress,
        allergies: c.allergies,
        photoUrl: photoUrl ?? c.photoUrl,
        scanCode: scanCode ?? c.scanCode,
        isActive: isActive ?? c.isActive,
        approvalStatus: c.approvalStatus,
        status: status ?? c.status,
        createdAt: c.createdAt,
        createdBy: c.createdBy,
        approvedAt: c.approvedAt,
        approvedBy: c.approvedBy,
        mother: c.mother,
        father: c.father,
        agreement: c.agreement,
        emergencyContacts: emergencyContacts ?? c.emergencyContacts,
        currentPlan: c.currentPlan,
      );
}
