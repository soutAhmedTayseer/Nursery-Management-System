import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  bool isPasswordObscure = true;

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    emit(LoginPasswordVisibilityChanged(isPasswordObscure));
  }
}