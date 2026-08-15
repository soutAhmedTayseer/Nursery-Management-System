import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/l10n/api_error_messages.dart';
import '../../../kids/data/repositories/kids_repository.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../../subscriptions/data/models/plan_assignment.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._kidsRepository, this._sessionsRepository)
      : super(RegistrationInitial());

  final KidsRepository _kidsRepository;
  final SessionsRepository _sessionsRepository;

  /// Creates the new Kid. [fullName]/[dateOfBirth]/[planCategory]/[planItem]
  /// are the only fields this step wires through today — the rest of the
  /// multi-step form isn't plumbed to a persistence layer yet, so those fields
  /// fall back to placeholders until that's built.
  ///
  /// The server assigns the id and the QR payload; neither is sent, and neither
  /// is derived here (contract §5 — the client never signs a QR).
  void registerChild({
    required String fullName,
    required DateTime? dateOfBirth,
    required PlanCategory planCategory,
    required PlanLineItem planItem,
    required String parentName,
    required String parentPhone,
    String? allergies,
  }) async {
    emit(RegistrationLoading());
    final name = fullName.trim().isEmpty ? 'Unnamed Child' : fullName.trim();

    try {
      final kid = await _kidsRepository.createKid(
        fullName: name,
        dateOfBirth: dateOfBirth ?? DateTime.now(),
        emergencyContactName: parentName,
        emergencyContactPhone: parentPhone,
        allergies: allergies,
      );

      // ponytail: Sessions is still fake, and addKid is what puts a child on
      // the roster. Without this the new child would create fine and then
      // vanish from the Sessions screen. Phase 3 wires Sessions to the API and
      // deletes this call.
      await _sessionsRepository.addKid(
        kid,
        planLabel: '${planCategory.name} · ${planItem.label}',
      );

      emit(RegistrationSuccess(PlanAssignment(
        kidId: kid.id,
        kidName: kid.fullName,
        parentName: parentName,
        parentPhone: parentPhone,
        categoryId: planCategory.id,
        lineItemId: planItem.id,
        assignedAt: DateTime.now(),
      )));
    } on ApiException catch (exception) {
      emit(RegistrationError(apiErrorMessage(exception)));
    }
  }
}
