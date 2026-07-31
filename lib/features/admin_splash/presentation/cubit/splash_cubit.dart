import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/repositories/auth_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._repository) : super(SplashInitial());

  final AuthRepository _repository;

  Future<void> checkSession() async {
    // A brief pause keeps the splash animation from flashing off-screen —
    // not a fixed timer gating navigation, the session check itself decides.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final hasSession = await _repository.hasSession();
    emit(hasSession ? SplashNavigateToLayout() : SplashNavigateToLogin());
  }
}
