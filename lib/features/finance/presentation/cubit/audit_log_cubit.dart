import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/repositories/audit_log_repository.dart';
import '../../domain/audit_entry.dart';

/// Append-only activity log, newest first.
///
/// Read-only by design: the server records each action as it handles it, so
/// this cubit has no `record` method. The point of an audit trail is that the
/// person being audited cannot rewrite it, and a client-side `record` call is
/// exactly that hole.
class AuditLogCubit extends Cubit<List<AuditEntry>> {
  AuditLogCubit(this._repository) : super(const []);

  final AuditLogRepository _repository;

  Future<void> load({String? subjectId}) async {
    try {
      emit(await _repository.fetchEntries(subjectId: subjectId));
    } on ApiException {
      // Keep whatever was last read rather than blanking the dialog; the
      // action that triggered this reports its own failure.
    }
  }

  List<AuditEntry> forSubject(String subjectId) =>
      state.where((entry) => entry.subjectId == subjectId).toList();
}
