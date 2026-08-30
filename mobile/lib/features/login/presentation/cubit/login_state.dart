abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginPasswordVisibilityChanged extends LoginState {
  final bool isObscure;
  LoginPasswordVisibilityChanged(this.isObscure);
}