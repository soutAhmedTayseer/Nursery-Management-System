import 'package:nursery_shared/nursery_shared.dart';

import '../models/finance_model.dart';
import 'finance_repository.dart';

class ApiFinanceRepository implements FinanceRepository {
  ApiFinanceRepository(this._client);

  final ApiClient _client;

  @override
  Future<FinanceSummary> fetchSummary() async {
    final response =
        await _client.get<Map<String, dynamic>>('/admin/finance/summary');
    return FinanceSummary.fromJson(response.data!);
  }

  @override
  Future<List<RevenueBucket>> fetchRevenue({
    required DateTime from,
    required DateTime to,
    required RevenueGranularity granularity,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/admin/finance/revenue',
      queryParameters: {
        'from': _date(from),
        'to': _date(to),
        'granularity': granularity.name,
      },
    );
    final buckets = response.data!['buckets'] as List<dynamic>? ?? const [];
    return [
      for (final bucket in buckets)
        RevenueBucket.fromJson(bucket as Map<String, dynamic>),
    ];
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Future<PaginatedResult<PaymentRecord>> fetchBalances({
    int page = 1,
    int pageSize = 20,
    String query = '',
    bool? isPaid,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/admin/finance/balances',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (query.trim().isNotEmpty) 'query': query.trim(),
        if (isPaid != null) 'status': isPaid ? 'paid' : 'unpaid',
      },
    );
    return PaginatedResult.fromJson(response.data!, PaymentRecord.fromJson);
  }

  @override
  Future<void> addManualCharge(
    String kidId, {
    required double amount,
    required String note,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/admin/kids/$kidId/charges',
      // `type` is always manual — automatic charges are generated server-side
      // on check-out (contract §3.9) and are never posted by a client.
      data: {'type': 'manual', 'amount': amount, 'note': note},
    );
  }

  @override
  Future<void> recordPayment(
    String kidId, {
    required double amount,
    required String method,
    String? note,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/admin/kids/$kidId/payments',
      data: {'amount': amount, 'method': method, 'note': ?note},
    );
  }
}
