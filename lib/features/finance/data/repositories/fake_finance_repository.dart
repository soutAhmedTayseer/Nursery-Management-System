import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/demo_seed.dart';
import '../../../../core/testing/fake_failure_switch.dart';
import '../models/finance_model.dart';
import 'finance_repository.dart';

/// In-memory [FinanceRepository] for the offline path.
///
/// It stands in for the server's arithmetic rather than reproducing it: the
/// figures below are plausible demo numbers, not a second implementation of the
/// billing rules. Duplicating those rules here is exactly what the contract
/// warns against — two implementations drift, and then the demo disagrees with
/// production about what a parent owes.
class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 300),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  late final List<PaymentRecord> _records = [
    for (final (index, child) in kDemoChildren.indexed)
      _record(child.id, child.fullName, child.parentName, child.parentPhone, index),
  ];

  final Set<String> _paid = {};

  @override
  Future<FinanceSummary> fetchSummary() async {
    await _tick();
    return FinanceSummary(
      revenueMonthToDate:
          _records.where((r) => _paid.contains(r.id)).fold(0.0, (s, r) => s + r.totalDue),
      totalOutstanding: _records
          .where((r) => !_paid.contains(r.id))
          .fold(0.0, (s, r) => s + r.totalDue),
      currency: 'AED',
    );
  }

  @override
  Future<List<RevenueBucket>> fetchRevenue({
    required DateTime from,
    required DateTime to,
    required RevenueGranularity granularity,
  }) async {
    await _tick();

    final step = switch (granularity) {
      RevenueGranularity.day => const Duration(days: 1),
      RevenueGranularity.week => const Duration(days: 7),
      RevenueGranularity.month => const Duration(days: 30),
    };

    // Deterministic per bucket so the demo chart doesn't reshuffle on rebuild.
    final buckets = <RevenueBucket>[];
    for (var start = from; start.isBefore(to); start = start.add(step)) {
      buckets.add(RevenueBucket(
        start: start,
        revenue: (start.day * 137 % 900) + 200,
      ));
    }
    return buckets;
  }

  @override
  Future<PaginatedResult<PaymentRecord>> fetchBalances({
    int page = 1,
    int pageSize = 20,
    String query = '',
    bool? isPaid,
  }) async {
    await _tick();

    final needle = query.trim().toLowerCase();
    final matches = _records.where((r) {
      final matchesQuery = needle.isEmpty ||
          r.childName.toLowerCase().contains(needle) ||
          r.parentName.toLowerCase().contains(needle);
      final paid = _paid.contains(r.id);
      return matchesQuery && (isPaid == null || paid == isPaid);
    }).toList();

    final start = (page - 1) * pageSize;
    final items = start >= matches.length
        ? <PaymentRecord>[]
        : matches.sublist(start, (start + pageSize).clamp(0, matches.length));

    return PaginatedResult(
      items: [for (final r in items) _withPaid(r, _paid.contains(r.id))],
      total: matches.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> addManualCharge(
    String kidId, {
    required double amount,
    required String note,
  }) async {
    await _tick();
    final index = _records.indexWhere((r) => r.id == kidId);
    if (index == -1) return;
    final existing = _records[index];
    _records[index] = _withTotals(existing, penalty: existing.penaltyAmount + amount);
    _paid.remove(kidId);
  }

  @override
  Future<void> recordPayment(
    String kidId, {
    required double amount,
    required String method,
    String? note,
  }) async {
    await _tick();
    _paid.add(kidId);
  }

  Future<void> _tick() async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
  }

  static PaymentRecord _record(
    String id,
    String childName,
    String parentName,
    String parentPhone,
    int index,
  ) {
    // Spread the demo roster across paid/unpaid and with/without overtime so
    // the table's filters have something to act on.
    final baseFee = 1000 + (index % 4) * 250.0;
    final overtimeHours = (index % 3) * 1.5;
    const overtimeRate = kDefaultOvertimeHourlyRate;
    final penalty = index % 5 == 0 ? kDefaultLatePickupFine : 0.0;
    final overtimeAmount = overtimeHours * overtimeRate;
    final total = baseFee + overtimeAmount + penalty;

    return PaymentRecord(
      id: id,
      parentName: parentName,
      childName: childName,
      parentPhone: parentPhone,
      baseFee: baseFee,
      overtimeHours: overtimeHours,
      overtimeRate: overtimeRate,
      overtimeAmount: overtimeAmount,
      penaltyAmount: penalty,
      totalDue: total,
      amountPaid: 0,
      outstanding: total,
      isPaid: false,
      currency: 'AED',
      avatarColor: avatarColorFor(id),
    );
  }

  static PaymentRecord _withPaid(PaymentRecord r, bool paid) => PaymentRecord(
        id: r.id,
        parentName: r.parentName,
        childName: r.childName,
        parentPhone: r.parentPhone,
        baseFee: r.baseFee,
        overtimeHours: r.overtimeHours,
        overtimeRate: r.overtimeRate,
        overtimeAmount: r.overtimeAmount,
        penaltyAmount: r.penaltyAmount,
        totalDue: r.totalDue,
        amountPaid: paid ? r.totalDue : 0,
        outstanding: paid ? 0 : r.totalDue,
        isPaid: paid,
        currency: r.currency,
        avatarColor: r.avatarColor,
      );

  static PaymentRecord _withTotals(PaymentRecord r, {required double penalty}) {
    final total = r.baseFee + r.overtimeAmount + penalty;
    return PaymentRecord(
      id: r.id,
      parentName: r.parentName,
      childName: r.childName,
      parentPhone: r.parentPhone,
      baseFee: r.baseFee,
      overtimeHours: r.overtimeHours,
      overtimeRate: r.overtimeRate,
      overtimeAmount: r.overtimeAmount,
      penaltyAmount: penalty,
      totalDue: total,
      amountPaid: 0,
      outstanding: total,
      isPaid: false,
      currency: r.currency,
      avatarColor: r.avatarColor,
    );
  }
}
