import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AdminLoginState {}
class AdminLoginInitial extends AdminLoginState {}
class AdminLoginLoading extends AdminLoginState {}
class AdminLoginSuccess extends AdminLoginState {}

class AdminLoginCubit extends Cubit<AdminLoginState> {
  AdminLoginCubit() : super(AdminLoginInitial());

  void login() async {
    emit(AdminLoginLoading());
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 2));
    emit(AdminLoginSuccess());
  }
}
