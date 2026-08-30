import 'package:nursery_shared/nursery_shared.dart';

import 'children_repository.dart';

/// Talks to the live `Admin Children` endpoints. Feature code never touches
/// `dio` directly - everything goes through [ApiClient].
class ApiChildrenRepository implements ChildrenRepository {
  ApiChildrenRepository(this.client);

  final ApiClient client;

  @override
  Future<PaginatedResult<ChildSummary>> fetchChildren({
    int page = 1,
    int pageSize = 20,
    String search = '',
    bool activeOnly = false,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      '/children',
      queryParameters: {
        'pageNumber': page,
        'pageSize': pageSize,
        'search': search,
        'activeOnly': activeOnly,
      },
    );
    return PaginatedResult.fromJson(
      response.data ?? const <String, dynamic>{},
      (json) => ChildSummary.fromJson(json),
    );
  }

  @override
  Future<Child> fetchChild(String id) async {
    final response = await client.get<Map<String, dynamic>>('/children/$id');
    return Child.fromJson(response.data ?? const <String, dynamic>{});
  }

  @override
  Future<ChildSummary?> createChild(ChildInput input) async {
    await client.post<dynamic>('/children', data: input.toCreateJson());
    // The API returns 200 with no body - no id to read back. Find the row we
    // just created in the roster by its natural key.
    final page = await fetchChildren(search: input.fullName, pageSize: 50);
    final enrolment = _dateOnly(input.enrollmentDate);
    for (final row in page.items) {
      if (row.fullName == input.fullName &&
          _dateOnly(row.enrollmentDate) == enrolment) {
        return row;
      }
    }
    return page.items.isEmpty ? null : page.items.first;
  }

  @override
  Future<Child> updateChild(String id, ChildInput input) async {
    await client.put<dynamic>('/children/$id', data: input.toUpdateJson());
    return fetchChild(id);
  }

  @override
  Future<Child> setActive(String id, {required bool isActive}) async {
    await client.put<dynamic>(
      '/children/$id/active',
      data: {'id': id, 'isActive': isActive},
    );
    return fetchChild(id);
  }

  @override
  Future<Child> setStatus(String id, ChildStatus status) async {
    await client.put<dynamic>(
      '/children/$id/status',
      data: {'status': status.wireValue},
    );
    return fetchChild(id);
  }

  @override
  Future<Child> regenerateScanCode(String id) async {
    await client.post<dynamic>('/children/$id/scan-code/regenerate');
    return fetchChild(id);
  }

  @override
  Future<Child> uploadPhoto(String id, String filePath) async {
    await client.postMultipart<dynamic>(
      '/children/$id/photo',
      filePath: filePath,
    );
    return fetchChild(id);
  }

  @override
  Future<Child> deletePhoto(String id) async {
    await client.delete<dynamic>('/children/$id/photo');
    return fetchChild(id);
  }

  @override
  Future<Child> addEmergencyContact(
    String childId,
    NewEmergencyContact contact,
  ) async {
    await client.post<dynamic>(
      '/children/$childId/emergency-contacts',
      data: {'childId': childId, ...contact.toJson()},
    );
    return fetchChild(childId);
  }

  @override
  Future<Child> removeEmergencyContact(String childId, String contactId) async {
    await client.delete<dynamic>(
      '/children/$childId/emergency-contacts/$contactId',
    );
    return fetchChild(childId);
  }
}

String? _dateOnly(DateTime? d) => d == null
    ? null
    : '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
