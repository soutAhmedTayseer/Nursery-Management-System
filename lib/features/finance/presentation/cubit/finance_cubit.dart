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
        avatarColor: Colors.grey.shade200,
        parentPhone: '971501234567',
      ),
      PaymentRecord(
        id: '2',
        parentName: 'James Khan',
        childName: 'Amara Khan',
        baseFee: 2500,
        overtimeHours: 4.5,
        penaltyAmount: 225,
        avatarColor: Colors.orange.shade100,
        parentPhone: '971502345678',
      ),
      PaymentRecord(
        id: '3',
        parentName: 'Emma Watson',
        childName: 'Noah Watson',
        baseFee: 2800,
        overtimeHours: 2.0,
        penaltyAmount: 100,
        avatarColor: Colors.blue.shade100,
        parentPhone: '971503456789',
      ),
    ];
    emit(FinanceState(payments: initialData, filteredPayments: initialData));
  }

  void addPayment(PaymentRecord newPayment) {
    final updatedList = List<PaymentRecord>.from(state.payments)..add(newPayment);
    _emitFiltered(updatedList, state.searchQuery, state.penaltyFilter);
  }

  void filterPayments(String query) {
    _emitFiltered(state.payments, query, state.penaltyFilter);
  }

  void setPenaltyFilter(PenaltyFilter filter) {
    _emitFiltered(state.payments, state.searchQuery, filter);
  }

  void setRevenuePeriod(RevenuePeriod period) {
    emit(state.copyWith(revenuePeriod: period));
  }

  void _emitFiltered(List<PaymentRecord> payments, String query, PenaltyFilter penaltyFilter) {
    emit(FinanceState(
      payments: payments,
      filteredPayments: _filterList(payments, query, penaltyFilter),
      searchQuery: query,
      penaltyFilter: penaltyFilter,
      revenuePeriod: state.revenuePeriod,
    ));
  }

  List<PaymentRecord> _filterList(List<PaymentRecord> list, String query, PenaltyFilter penaltyFilter) {
    return list.where((p) {
      final matchesQuery = query.isEmpty ||
          p.parentName.toLowerCase().contains(query.toLowerCase()) ||
          p.childName.toLowerCase().contains(query.toLowerCase());
      final matchesPenalty = switch (penaltyFilter) {
        PenaltyFilter.all => true,
        PenaltyFilter.withPenalty => p.penaltyAmount > 0,
        PenaltyFilter.withoutPenalty => p.penaltyAmount == 0,
      };
      return matchesQuery && matchesPenalty;
    }).toList();
  }
}
