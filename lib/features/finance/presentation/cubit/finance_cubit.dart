import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/finance_model.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit() : super(FinanceState(payments: [], filteredPayments: [])) {
    loadInitialData();
  }

  void loadInitialData() {
    final initialData = [
      PaymentRecord(
        id: '1', 
        parentName: 'Sarah Mitchell', 
        childName: 'Leo Mitchell', 
        baseFee: 2500, 
        overtimeHours: 0, 
        penaltyAmount: 0, 
        avatarColor: Colors.grey.shade200
      ),
      PaymentRecord(
        id: '2', 
        parentName: 'James Khan', 
        childName: 'Amara Khan', 
        baseFee: 2500, 
        overtimeHours: 4.5, 
        penaltyAmount: 225, 
        avatarColor: Colors.orange.shade100
      ),
      PaymentRecord(
        id: '3', 
        parentName: 'Emma Watson', 
        childName: 'Noah Watson', 
        baseFee: 2800, 
        overtimeHours: 2.0, 
        penaltyAmount: 100, 
        avatarColor: Colors.blue.shade100
      ),
    ];
    emit(FinanceState(payments: initialData, filteredPayments: initialData));
  }

  void addPayment(PaymentRecord newPayment) {
    final updatedList = List<PaymentRecord>.from(state.payments)..add(newPayment);
    emit(FinanceState(
      payments: updatedList, 
      filteredPayments: _filterList(updatedList, state.searchQuery),
      searchQuery: state.searchQuery,
    ));
  }

  void filterPayments(String query) {
    emit(FinanceState(
      payments: state.payments, 
      filteredPayments: _filterList(state.payments, query), 
      searchQuery: query
    ));
  }

  List<PaymentRecord> _filterList(List<PaymentRecord> list, String query) {
    if (query.isEmpty) return list;
    return list.where((p) => 
      p.parentName.toLowerCase().contains(query.toLowerCase()) || 
      p.childName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
