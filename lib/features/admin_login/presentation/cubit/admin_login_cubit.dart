import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../auth/data/repositories/auth_repository.dart';

abstract class AdminLoginState {}

class AdminLoginInitial extends AdminLoginState {}

class AdminLoginLoading extends AdminLoginState {}

class AdminLoginSuccess extends AdminLoginState {}

class AdminLoginError extends AdminLoginState {
  AdminLoginError(this.exception);
  final ApiException exception;
}

class AdminLoginCubit extends Cubit<AdminLoginState> {
  AdminLoginCubit(this._repository) : super(AdminLoginInitial());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    emit(AdminLoginLoading());
    try {
      await _repository.login(email: email, password: password);
      emit(AdminLoginSuccess());
    } on ApiException catch (exception) {
      emit(AdminLoginError(exception));
    }
  }
}
