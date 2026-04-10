import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../data/models/child_session_model.dart';
part 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit() : super(SessionsInitial());

  List<ChildSessionModel> allKids = [];
  final int itemsPerPage = 8;
  String currentQuery = "";
  int currentPage = 1;

  void loadSessions() {
    emit(SessionsLoading());
    // Sample data for testing pagination
    allKids = [
      ChildSessionModel(id: '1', name: 'Leo Maxwell', image: 'assets/images/child_1.png', subscription: 'Full-time', isCheckedIn: true, duration: '03h 42m'),
      ChildSessionModel(id: '2', name: 'Amira Khalid', image: 'assets/images/child_2.png', subscription: '3 Days/Week', isCheckedIn: false),
      ChildSessionModel(id: '3', name: 'Noah James', image: 'assets/images/child_3.png', subscription: 'Full-time', isCheckedIn: true, duration: '01h 15m'),
      ChildSessionModel(id: '4', name: 'Sophie Liam', image: 'assets/images/child_1.png', subscription: 'Full-time', isCheckedIn: true, duration: '04h 50m'),
      ChildSessionModel(id: '5', name: 'Ethan Wright', image: 'assets/images/child_2.png', subscription: 'Mornings Only', isCheckedIn: false),
      ChildSessionModel(id: '6', name: 'Maya Rose', image: 'assets/images/child_3.png', subscription: 'Full-time', isCheckedIn: true, duration: '02h 10m'),
      ChildSessionModel(id: '7', name: 'Oliver Smith', image: 'assets/images/child_1.png', subscription: 'Full-time', isCheckedIn: true, duration: '01h 00m'),
      ChildSessionModel(id: '8', name: 'Emma Davis', image: 'assets/images/child_2.png', subscription: '3 Days/Week', isCheckedIn: false),
      ChildSessionModel(id: '9', name: 'Lucas Brown', image: 'assets/images/child_3.png', subscription: 'Mornings Only', isCheckedIn: true, duration: '02h 30m'),
      ChildSessionModel(id: '10', name: 'Mia Wilson', image: 'assets/images/child_1.png', subscription: 'Full-time', isCheckedIn: false),
      ChildSessionModel(id: '11', name: 'Aiden Taylor', image: 'assets/images/child_2.png', subscription: 'Full-time', isCheckedIn: true, duration: '04h 10m'),
      ChildSessionModel(id: '12', name: 'Isabella Moore', image: 'assets/images/child_3.png', subscription: '3 Days/Week', isCheckedIn: false),
    ];
    _updateState();
  }

  void search(String query) {
    currentQuery = query;
    currentPage = 1; // Always return to first page on search
    _updateState();
  }

  void changePage(int page) {
    currentPage = page;
    _updateState();
  }

  void _updateState() {
    // 1. Filter data first
    final filtered = allKids.where((k) => k.name.toLowerCase().contains(currentQuery.toLowerCase())).toList();
    
    // 2. Calculate number of pages
    final totalCount = filtered.length;
    final totalPages = max(1, (totalCount / itemsPerPage).ceil());
    
    // 3. Secure current page
    currentPage = currentPage > totalPages ? totalPages : currentPage;

    // 4. Slicing data for the current page
    final startIndex = (currentPage - 1) * itemsPerPage;
    final displayed = filtered.skip(startIndex).take(itemsPerPage).toList();

    emit(SessionsLoaded(
      displayedKids: displayed,
      totalCount: totalCount,
      searchQuery: currentQuery,
      currentPage: currentPage,
      totalPages: totalPages,
    ));
  }
}
