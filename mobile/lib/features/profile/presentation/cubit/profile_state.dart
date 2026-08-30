abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLogoutLoading extends ProfileState {}
class ProfileLogoutSuccess extends ProfileState {}
class ProfileEditLoading extends ProfileState {}
class ProfileEditSuccess extends ProfileState {}
class ProfileEditError extends ProfileState {
  final String message;
  ProfileEditError(this.message);
}