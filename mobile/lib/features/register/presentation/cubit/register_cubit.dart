import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    emit(RegisterVisibilityChanged());
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure = !isConfirmPasswordObscure;
    emit(RegisterVisibilityChanged());
  }
}