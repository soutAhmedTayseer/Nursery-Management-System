import '../../data/models/finance_model.dart';

class FinanceState {
  final List<PaymentRecord> payments;
  final List<PaymentRecord> filteredPayments;
  final String searchQuery;

  FinanceState({
    required this.payments, 
    required this.filteredPayments, 
    this.searchQuery = "",
  });
}
