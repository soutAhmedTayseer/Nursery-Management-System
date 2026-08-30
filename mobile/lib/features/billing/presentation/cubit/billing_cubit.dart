import 'package:flutter_bloc/flutter_bloc.dart';
import 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  BillingCubit() : super(BillingInitial());

  // بيانات الطفل الحالي (نفس فكرة الـ History)
  Map<String, String> selectedChild = {
    'name': 'Leo Alexander',
    'image': 'assets/images/child_1.png'
  };

  final List<Map<String, String>> childrenList = [
    {'name': 'Leo Alexander', 'image': 'assets/images/child_1.png'},
    {'name': 'Mia Woods', 'image': 'assets/images/child_2.png'},
  ];

  void changeChild(Map<String, String> child) {
    selectedChild = child;
    emit(BillingChildChanged());
  }
}