import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/services/qr_code_service.dart';
import '../../../sessions/data/repositories/sessions_repository.dart';
import '../../../subscriptions/data/models/plan_assignment.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._sessionsRepository) : super(RegistrationInitial());

  final SessionsRepository _sessionsRepository;

  /// Builds and saves the new Kid, generating its clock-in/out QR from the
  /// new id. [fullName]/[dateOfBirth]/[planCategory]/[planItem] are the only
  /// fields this step wires through today — the rest of the multi-step form
  /// (parents, emergency contact, etc.) isn't yet plumbed to a persistence
  /// layer, so those fields fall back to placeholders until that's built.
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
    // Simulate registration process and data upload to API
    await Future.delayed(const Duration(seconds: 2));
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final name = fullName.trim().isEmpty ? 'Unnamed Child' : fullName.trim();
    final kid = Kid(
      id: id,
      fullName: name,
      dateOfBirth: dateOfBirth ?? DateTime.now(),
      photoUrl: '',
      status: KidStatus.active,
      allergies: allergies,
      medicalNotes: null,
      emergencyContactName: parentName,
      emergencyContactPhone: parentPhone,
      createdBy: 'admin',
      createdAt: DateTime.now(),
      approvedAt: DateTime.now(),
      approvedBy: 'admin',
      qrPayload: QrCodeService.signKidId(id),
    );
    await _sessionsRepository.addKid(kid, planLabel: '${planCategory.name} · ${planItem.label}');
    emit(RegistrationSuccess(PlanAssignment(
      kidId: id,
      kidName: name,
      parentName: parentName,
      parentPhone: parentPhone,
      categoryId: planCategory.id,
      lineItemId: planItem.id,
      assignedAt: DateTime.now(),
    )));
  }
}
