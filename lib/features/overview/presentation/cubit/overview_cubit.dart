import 'package:flutter_bloc/flutter_bloc.dart';
import 'overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit() : super(OverviewInitial());

  void fetchDashboardData() async {
    emit(OverviewLoading());
    // محاكاة جلب البيانات من الـ API
    await Future.delayed(const Duration(milliseconds: 800));
    emit(OverviewLoaded());
  }
}