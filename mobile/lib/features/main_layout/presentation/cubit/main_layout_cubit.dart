import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_layout_state.dart';

class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(MainLayoutInitial());

  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    emit(MainLayoutIndexChanged(currentIndex));
  }
}