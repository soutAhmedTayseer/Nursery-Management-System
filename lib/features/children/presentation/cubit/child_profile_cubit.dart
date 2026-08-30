import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/repositories/children_repository.dart';

abstract class ChildProfileState {}

class ChildProfileInitial extends ChildProfileState {}

class ChildProfileLoading extends ChildProfileState {}

/// The child is on screen. [mutating] is true while a write is in flight;
/// [error] carries the last failed write so the screen can show a snackbar
/// without losing the profile.
class ChildProfileLoaded extends ChildProfileState {
  ChildProfileLoaded(this.child, {this.mutating = false, this.error});

  final Child child;
  final bool mutating;
  final ApiException? error;
}

class ChildProfileError extends ChildProfileState {
  ChildProfileError(this.exception);
  final ApiException exception;
}

/// Drives the Child Profile screen: one child plus the writes reachable from
/// it (photo, scan code, status, emergency contacts).
class ChildProfileCubit extends Cubit<ChildProfileState> {
  ChildProfileCubit(this._repository, this.childId)
      : super(ChildProfileInitial());

  final ChildrenRepository _repository;
  final String childId;

  Child? get _current {
    final s = state;
    return s is ChildProfileLoaded ? s.child : null;
  }

  Future<void> load() async {
    emit(ChildProfileLoading());
    try {
      emit(ChildProfileLoaded(await _repository.fetchChild(childId)));
    } on ApiException catch (e) {
      emit(ChildProfileError(e));
    } catch (_) {
      emit(ChildProfileError(const ApiException(
        code: 'UNKNOWN',
        message: 'Unexpected error',
        statusCode: null,
      )));
    }
  }

  Future<void> updateChild(ChildInput input) =>
      _mutate(() => _repository.updateChild(childId, input));

  Future<void> uploadPhoto(String filePath) =>
      _mutate(() => _repository.uploadPhoto(childId, filePath));

  Future<void> deletePhoto() =>
      _mutate(() => _repository.deletePhoto(childId));

  Future<void> regenerateScanCode() =>
      _mutate(() => _repository.regenerateScanCode(childId));

  Future<void> setStatus(ChildStatus status) =>
      _mutate(() => _repository.setStatus(childId, status));

  Future<void> setActive({required bool isActive}) =>
      _mutate(() => _repository.setActive(childId, isActive: isActive));

  Future<void> addEmergencyContact(NewEmergencyContact contact) =>
      _mutate(() => _repository.addEmergencyContact(childId, contact));

  Future<void> removeEmergencyContact(String contactId) =>
      _mutate(() => _repository.removeEmergencyContact(childId, contactId));

  Future<void> _mutate(Future<Child> Function() action) async {
    final current = _current;
    if (current == null) return;
    emit(ChildProfileLoaded(current, mutating: true));
    try {
      emit(ChildProfileLoaded(await action()));
    } on ApiException catch (e) {
      emit(ChildProfileLoaded(current, error: e));
    }
  }
}
