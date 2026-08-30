import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../account/data/repositories/account_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authRepository, this._accountRepository, this._tokenStorage)
      : super(SplashInitial());

  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;
  final TokenStorage _tokenStorage;

  Future<void> checkSession() async {
    // A brief pause keeps the splash animation from flashing off-screen —
    // not a fixed timer gating navigation, the session check itself decides.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    try {
      if (!await _authRepository.hasSession()) {
        emit(SplashNavigateToLogin());
        return;
      }
      // A token on disk isn't proof it still works. Probe /account/me so a
      // revoked or expired session lands on login instead of flashing the
      // dashboard until the first real request 401s. The ApiClient's
      // interceptor still gets its one refresh-and-retry attempt here.
      await _accountRepository.fetchMe();
      emit(SplashNavigateToLayout());
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        // Stale or revoked — drop the dead token so the next launch is clean.
        await _tokenStorage.clear();
        emit(SplashNavigateToLogin());
      } else {
        // Network down or server error — the token may still be valid. Don't
        // force a login the user might not be able to complete offline; open
        // the app and let its own screens surface the connectivity problem.
        emit(SplashNavigateToLayout());
      }
    } catch (_) {
      // Fail closed: a corrupt/locked secure-storage read or a network blip
      // must not hang the splash forever — send the user to login.
      emit(SplashNavigateToLogin());
    }
  }
}
