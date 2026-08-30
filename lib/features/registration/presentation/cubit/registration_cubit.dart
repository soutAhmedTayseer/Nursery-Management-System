import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../children/data/repositories/children_repository.dart';
import 'registration_state.dart';

/// Creates a real child through `POST /api/children`.
///
/// Plan assignment (`POST /api/planassignments`) is Phase 3 - the picked plan
/// is validated in the form but not sent yet.
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._children) : super(RegistrationInitial());

  final ChildrenRepository _children;

  Future<void> submit(ChildInput input) async {
    emit(RegistrationLoading());
    try {
      final created = await _children.createChild(input);
      emit(RegistrationSuccess(created));
    } on ApiException catch (e) {
      emit(RegistrationError(e.message));
    } catch (_) {
      emit(RegistrationError('registration_error_generic'));
    }
  }
}
