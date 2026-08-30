abstract class MainLayoutState {}
class MainLayoutInitial extends MainLayoutState {}
class MainLayoutIndexChanged extends MainLayoutState {
  final int index;
  MainLayoutIndexChanged(this.index);
}