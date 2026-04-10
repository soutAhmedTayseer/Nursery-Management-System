import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_main_layout_state.dart';

class AdminMainLayoutCubit extends Cubit<AdminMainLayoutState> {
  AdminMainLayoutCubit() : super(AdminMainLayoutInitial());

  int currentIndex = 0;

  void changeScreen(int index) {
    currentIndex = index;
    emit(AdminMainLayoutIndexChanged(currentIndex));
  }
}
