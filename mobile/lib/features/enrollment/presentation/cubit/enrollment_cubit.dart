import 'package:flutter_bloc/flutter_bloc.dart';
import 'enrollment_state.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  EnrollmentCubit() : super(EnrollmentInitial());

  int currentStep = 0;
  final int totalSteps = 4;

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      emit(EnrollmentStepChanged(currentStep));
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      emit(EnrollmentStepChanged(currentStep));
    }
  }
}