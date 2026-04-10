import 'package:flutter_bloc/flutter_bloc.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit() : super(RegistrationInitial());

  void registerChild() async {
    emit(RegistrationLoading());
    // Simulate registration process and data upload to API
    await Future.delayed(const Duration(seconds: 2));
    emit(RegistrationSuccess());
  }
}
