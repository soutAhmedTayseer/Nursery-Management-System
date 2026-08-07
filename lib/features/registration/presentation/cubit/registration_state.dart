import '../../../subscriptions/data/models/plan_assignment.dart';

abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  RegistrationSuccess(this.assignment);

  /// The new child's plan subscription. The screen hands this to
  /// PlanAssignmentsCubit (app-root) so the child shows up in Finance's
  /// payments table and Add Invoice — registering only added them to the
  /// Sessions roster before, so they never reached Finance at all.
  final PlanAssignment assignment;
}

class RegistrationError extends RegistrationState {
  final String message;
  RegistrationError(this.message);
}
