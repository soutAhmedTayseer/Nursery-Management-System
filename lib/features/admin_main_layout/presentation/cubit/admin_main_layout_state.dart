abstract class AdminMainLayoutState {}
class AdminMainLayoutInitial extends AdminMainLayoutState {}
class AdminMainLayoutIndexChanged extends AdminMainLayoutState {
  final int index;
  AdminMainLayoutIndexChanged(this.index);
}
