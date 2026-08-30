import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_parents_system/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void logout() {
    emit(ProfileLogoutLoading());
    Future.delayed(const Duration(seconds: 2), () {
      emit(ProfileLogoutSuccess());
    });
  }
  void updateProfile({required String name, required String email, required String phone}) {
    emit(ProfileEditLoading());

    Future.delayed(const Duration(seconds: 2), () {
      emit(ProfileEditSuccess());
    });
  }
}