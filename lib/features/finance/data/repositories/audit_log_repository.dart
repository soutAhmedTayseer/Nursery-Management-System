import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import '../../domain/audit_entry.dart';

/// Read-only history of admin actions (contract §4 "Audit log").
///
/// There is no write method, and that is deliberate: the server appends an
/// entry itself when it handles the action. A log a client can write to is a
/// log the person being audited can forge.
abstract class AuditLogRepository {
  Future<List<AuditEntry>> fetchEntries({String? subjectId});
}

class ApiAuditLogRepository implements AuditLogRepository {
  ApiAuditLogRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AuditEntry>> fetchEntries({String? subjectId}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/admin/audit-log',
      queryParameters: {'subject_id': ?subjectId},
    );
    return PaginatedResult.fromJson(response.data!, AuditEntry.fromJson).items;
  }
}

/// Offline stand-in. Empty rather than fabricated: an invented audit trail is
/// worse than an obviously absent one.
class FakeAuditLogRepository implements AuditLogRepository {
  FakeAuditLogRepository({required this.failureSwitch});

  final FakeFailureSwitch failureSwitch;

  @override
  Future<List<AuditEntry>> fetchEntries({String? subjectId}) async {
    failureSwitch.maybeThrow();
    return const [];
  }
}
