import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/models/account.dart';
import '../../data/repositories/account_repository.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  AccountLoaded(this.account);
  final Account account;
}

class AccountError extends AccountState {
  AccountError(this.exception);
  final ApiException exception;
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._repository) : super(AccountInitial());

  final AccountRepository _repository;

  Future<void> load() async {
    emit(AccountLoading());
    try {
      emit(AccountLoaded(await _repository.fetchMe()));
    } on ApiException catch (e) {
      emit(AccountError(e));
    } catch (_) {
      emit(AccountError(const ApiException(
        code: '',
        message: 'Unexpected error',
        statusCode: null,
      )));
    }
  }

  /// Saves name + phone. Keeps the last good [AccountLoaded] on failure so
  /// the form stays populated; the screen surfaces the error separately.
  Future<void> save({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final updated = await _repository.updateMe(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      emit(AccountLoaded(updated));
    } on ApiException catch (e) {
      emit(AccountError(e));
    }
  }

  /// Drops the cached profile on logout so the next user never sees the
  /// previous one.
  void reset() => emit(AccountInitial());

  /// Rethrows `ApiException` so the change-password dialog can show it
  /// inline without the whole screen dropping to an error state.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
