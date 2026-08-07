import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/audit_entry.dart';

/// Append-only activity log, newest first. Lives at app root (bootstrap.dart)
/// so it spans every screen.
///
/// Deliberately has no delete or edit: the point of an audit trail is that
/// it can't be rewritten by the person being audited. When roles arrive,
/// this is what a head admin reads to see what each sub-admin did.
class AuditLogCubit extends Cubit<List<AuditEntry>> {
  AuditLogCubit() : super(const []);

  void record(AuditEntry entry) => emit([entry, ...state]);

  List<AuditEntry> forSubject(String subjectId) =>
      state.where((entry) => entry.subjectId == subjectId).toList();
}
