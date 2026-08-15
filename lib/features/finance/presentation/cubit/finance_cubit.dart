import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../data/repositories/finance_repository.dart';
import 'finance_state.dart';

/// The payments table, backed by `/admin/finance/*`.
///
/// Every figure it shows is computed server-side — this cubit fetches and
/// filters, it does not do arithmetic on money (contract §2). Writes are **not**
/// optimistic here, unlike the plan catalog: recording a payment that the server
/// rejected must never appear on screen as settled, so the row only changes
/// after the server confirms.
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit(this._repository) : super(const FinanceState());

  final FinanceRepository _repository;

  static const _pageSize = 50;

  RevenueGranularity _granularity = RevenueGranularity.month;

  /// How far back each granularity looks — the chart shows a fixed number of
  /// buckets, so the range follows from the bucket size.
  static const _spanByGranularity = {
    RevenueGranularity.day: Duration(days: 7),
    RevenueGranularity.week: Duration(days: 28),
    RevenueGranularity.month: Duration(days: 120),
  };

  Future<void> setGranularity(RevenueGranularity granularity) {
    _granularity = granularity;
    return load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final balances = await _repository.fetchBalances(
        pageSize: _pageSize,
        query: state.searchQuery,
      );
      final summary = await _repository.fetchSummary();
      final now = DateTime.now();
      final revenue = await _repository.fetchRevenue(
        from: now.subtract(_spanByGranularity[_granularity]!),
        to: now.add(const Duration(days: 1)),
        granularity: _granularity,
      );
      emit(state.copyWith(
        records: balances.items,
        summary: summary,
        revenue: revenue,
        isLoading: false,
        clearError: true,
      ));
    } on ApiException catch (exception) {
      emit(state.copyWith(isLoading: false, error: exception));
    }
  }

  /// Adds a manual charge, then re-reads so the new totals come from the
  /// server rather than being patched together locally.
  Future<void> addCharge(
    String kidId, {
    required double amount,
    required String note,
  }) =>
      _write(() => _repository.addManualCharge(kidId, amount: amount, note: note));

  /// Records money received. One-way on purpose — a payment is not something an
  /// admin should be able to quietly un-record.
  Future<void> recordPayment(
    String kidId, {
    required double amount,
    required String method,
    String? note,
  }) =>
      _write(() => _repository.recordPayment(
            kidId,
            amount: amount,
            method: method,
            note: note,
          ));

  Future<void> search(String query) {
    emit(state.copyWith(searchQuery: query));
    return load();
  }

  void setPenaltyFilter(PenaltyFilter filter) =>
      emit(state.copyWith(penaltyFilter: filter));

  Future<void> _write(Future<void> Function() request) async {
    emit(state.copyWith(clearError: true));
    try {
      await request();
      await load();
    } on ApiException catch (exception) {
      // No optimistic update to roll back — nothing changed on screen, and the
      // admin is told the write did not land.
      emit(state.copyWith(error: exception));
    }
  }
}
