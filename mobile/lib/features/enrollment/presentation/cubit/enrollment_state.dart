abstract class EnrollmentState {}
class EnrollmentInitial extends EnrollmentState {}
class EnrollmentStepChanged extends EnrollmentState {
  final int step;
  EnrollmentStepChanged(this.step);
}