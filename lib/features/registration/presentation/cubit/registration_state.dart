import 'package:nursery_shared/nursery_shared.dart';

abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  RegistrationSuccess(this.child);

  /// The freshly created child as read back from `GET /api/children`. Null
  /// when the API gave us no way to locate the new row (it returns no id on
  /// create) - the child was still created.
  final ChildSummary? child;
}

class RegistrationError extends RegistrationState {
  RegistrationError(this.message);

  /// Either a translation key (client-side failures) or a human message from
  /// the API's Problem Details `detail`.
  final String message;
}
