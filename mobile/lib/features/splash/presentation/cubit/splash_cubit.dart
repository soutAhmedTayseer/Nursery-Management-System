import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void executeSplashTimer() async {
    await Future.delayed(const Duration(seconds: 4));
    
    emit(SplashNavigateToLogin());
  }
}
