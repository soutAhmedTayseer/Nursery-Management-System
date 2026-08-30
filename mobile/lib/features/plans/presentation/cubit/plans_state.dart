abstract class PlansState {}
class PlansInitial extends PlansState {}
class PlanSelected extends PlansState {
  final String planName;
  PlanSelected(this.planName);
}