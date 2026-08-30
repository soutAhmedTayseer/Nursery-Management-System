import 'package:flutter_bloc/flutter_bloc.dart';
import '  history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial());

  Map<String, String> selectedChild = {
    'name': 'Leo Alexander',
    'image': 'assets/images/child_1.png'
  };

  String selectedMonth = 'October 2023';

  final List<Map<String, String>> childrenList = [
    {'name': 'Leo Alexander', 'image': 'assets/images/child_1.png'},
    {'name': 'Mia Woods', 'image': 'assets/images/child_2.png'},
    {'name': 'Noah Smith', 'image': 'assets/images/child_3.png'},
  ];

  final List<String> months = ['August 2023', 'September 2023', 'October 2023', 'November 2023'];

  void changeChild(Map<String, String> child) {
    selectedChild = child;
    emit(HistoryFilterChanged());
  }

  void changeMonth(String month) {
    selectedMonth = month;
    emit(HistoryFilterChanged());
  }
}