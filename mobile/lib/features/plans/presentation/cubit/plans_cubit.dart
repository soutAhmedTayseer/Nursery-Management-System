import 'package:flutter_bloc/flutter_bloc.dart';
import 'plans_state.dart';

class PlansCubit extends Cubit<PlansState> {
  PlansCubit() : super(PlansInitial());

  void selectPlan(String planName) {
    emit(PlanSelected(planName));
  }
}