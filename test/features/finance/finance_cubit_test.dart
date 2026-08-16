import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nursery_management_system/features/finance/data/models/finance_model.dart';
import 'package:nursery_management_system/features/finance/data/repositories/finance_repository.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_state.dart';
import 'package:nursery_shared/nursery_shared.dart';

class _MockFinanceRepository extends Mock implements FinanceRepository {}

PaymentRecord _record(
  String id, {
  double penalty = 0,
  bool isPaid = false,
}) =>
    PaymentRecord(
      id: id,
      parentName: 'Parent $id',
      childName: 'Child $id',
      baseFee: 1000,
      overtimeHours: 2,
      overtimeRate: 25,
      overtimeAmount: 50,
      penaltyAmount: penalty,
      totalDue: 1050 + penalty,
      amountPaid: isPaid ? 1050 + penalty : 0,
      outstanding: isPaid ? 0 : 1050 + penalty,
      isPaid: isPaid,
      currency: 'AED',
      avatarColor: Colors.green,
    );

const _summary = FinanceSummary(
  revenueMonthToDate: 4200,
  totalOutstanding: 3150,
  currency: 'AED',
);

const _boom = ApiException(
  code: 'SERVER_ERROR',
  message: 'boom',
  statusCode: 500,
);

void main() {
  late _MockFinanceRepository repository;

  void stubReads({List<PaymentRecord>? records}) {
    when(() => repository.fetchBalances(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          query: any(named: 'query'),
          isPaid: any(named: 'isPaid'),
        )).thenAnswer((_) async => PaginatedResult(
          items: records ?? [_record('k1')],
          total: 1,
          page: 1,
          pageSize: 50,
        ));
    when(repository.fetchSummary).thenAnswer((_) async => _summary);
    when(() => repository.fetchRevenue(
          from: any(named: 'from'),
          to: any(named: 'to'),
          granularity: any(named: 'granularity'),
        )).thenAnswer((_) async => [
          RevenueBucket(start: DateTime(2026, 8, 14), revenue: 900),
        ]);
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(RevenueGranularity.month);
  });

  setUp(() => repository = _MockFinanceRepository());

  blocTest<FinanceCubit, FinanceState>(
    'load fetches balances, summary and the revenue series',
    setUp: stubReads,
    build: () => FinanceCubit(repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.records.single.id, 'k1');
      expect(cubit.state.summary!.totalOutstanding, 3150);
      expect(cubit.state.revenue.single.revenue, 900);
      expect(cubit.state.error, isNull);
    },
  );

  blocTest<FinanceCubit, FinanceState>(
    'surfaces a failed read',
    setUp: () {
      when(() => repository.fetchBalances(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: any(named: 'query'),
            isPaid: any(named: 'isPaid'),
          )).thenThrow(_boom);
    },
    build: () => FinanceCubit(repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, _boom);
    },
  );

  group('recordPayment', () {
    blocTest<FinanceCubit, FinanceState>(
      're-reads from the server rather than patching the row locally',
      setUp: () {
        stubReads();
        when(() => repository.recordPayment(
              any(),
              amount: any(named: 'amount'),
              method: any(named: 'method'),
              note: any(named: 'note'),
            )).thenAnswer((_) async {});
      },
      build: () => FinanceCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.recordPayment('k1', amount: 1050, method: 'cash');
      },
      verify: (_) {
        verify(repository.fetchSummary).called(2);
      },
    );

    blocTest<FinanceCubit, FinanceState>(
      'a rejected payment reports the error and settles nothing',
      setUp: () {
        stubReads();
        when(() => repository.recordPayment(
              any(),
              amount: any(named: 'amount'),
              method: any(named: 'method'),
              note: any(named: 'note'),
            )).thenThrow(_boom);
      },
      build: () => FinanceCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.recordPayment('k1', amount: 1050, method: 'cash');
      },
      verify: (cubit) {
        // The row must never read as settled off the back of a failed write —
        // an invoice that looks paid and is not is the worst failure here.
        expect(cubit.state.records.single.isPaid, isFalse);
        expect(cubit.state.error, _boom);
      },
    );
  });

  blocTest<FinanceCubit, FinanceState>(
    'addCharge posts a manual charge and re-reads',
    setUp: () {
      stubReads();
      when(() => repository.addManualCharge(
            any(),
            amount: any(named: 'amount'),
            note: any(named: 'note'),
          )).thenAnswer((_) async {});
    },
    build: () => FinanceCubit(repository),
    act: (cubit) async {
      await cubit.load();
      await cubit.addCharge('k1', amount: 50, note: 'Late pickup');
    },
    verify: (_) => verify(() => repository.addManualCharge(
          'k1',
          amount: 50,
          note: 'Late pickup',
        )).called(1),
  );

  group('penalty filter', () {
    blocTest<FinanceCubit, FinanceState>(
      'narrows the fetched page without refetching',
      setUp: () => stubReads(records: [
        _record('k1', penalty: 50),
        _record('k2'),
        _record('k3', isPaid: true),
      ]),
      build: () => FinanceCubit(repository),
      act: (cubit) async {
        await cubit.load();
        cubit.setPenaltyFilter(PenaltyFilter.withPenalty);
      },
      verify: (cubit) {
        expect(cubit.state.visibleRecords.single.id, 'k1');
        // Filtering is a view over the page already fetched.
        verify(repository.fetchSummary).called(1);
      },
    );

    blocTest<FinanceCubit, FinanceState>(
      'paid and unpaid split the roster',
      setUp: () => stubReads(records: [
        _record('k1'),
        _record('k2', isPaid: true),
      ]),
      build: () => FinanceCubit(repository),
      act: (cubit) async {
        await cubit.load();
        cubit.setPenaltyFilter(PenaltyFilter.paid);
      },
      verify: (cubit) => expect(cubit.state.visibleRecords.single.id, 'k2'),
    );
  });

  blocTest<FinanceCubit, FinanceState>(
    'search refetches, since it decides which rows the page holds at all',
    setUp: stubReads,
    build: () => FinanceCubit(repository),
    act: (cubit) async {
      await cubit.load();
      await cubit.search('omar');
    },
    verify: (cubit) {
      expect(cubit.state.searchQuery, 'omar');
      verify(() => repository.fetchBalances(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            query: 'omar',
            isPaid: any(named: 'isPaid'),
          )).called(1);
    },
  );
}
