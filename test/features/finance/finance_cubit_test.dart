import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:nursery_management_system/features/finance/presentation/cubit/finance_state.dart';

void main() {
  blocTest<FinanceCubit, FinanceState>(
    'marking an invoice paid records the kid',
    build: FinanceCubit.new,
    act: (cubit) => cubit.markPaid('kid-01'),
    expect: () => [
      isA<FinanceState>().having((s) => s.paidKidIds, 'paid', contains('kid-01')),
    ],
  );

  blocTest<FinanceCubit, FinanceState>(
    'settling is one-way — marking paid twice emits nothing the second time',
    build: FinanceCubit.new,
    act: (cubit) {
      cubit.markPaid('kid-01');
      cubit.markPaid('kid-01');
    },
    expect: () => [
      isA<FinanceState>().having((s) => s.paidKidIds, 'paid', contains('kid-01')),
    ],
  );

  blocTest<FinanceCubit, FinanceState>(
    're-invoicing a settled child reopens their balance',
    build: FinanceCubit.new,
    act: (cubit) {
      cubit.markPaid('kid-01');
      cubit.setExtras('kid-01', overtimeHours: 2, penaltyAmount: 50);
    },
    verify: (cubit) {
      expect(cubit.state.paidKidIds, isNot(contains('kid-01')));
      expect(cubit.state.extrasByKidId['kid-01']!.overtimeHoursOverride, 2);
      expect(cubit.state.extrasByKidId['kid-01']!.penaltyOverride, 50);
    },
  );

  blocTest<FinanceCubit, FinanceState>(
    'null overtime keeps trusting the attendance ledger',
    build: FinanceCubit.new,
    act: (cubit) => cubit.setExtras('kid-01', penaltyAmount: 0),
    verify: (cubit) {
      expect(cubit.state.extrasByKidId['kid-01']!.overtimeHoursOverride, isNull);
    },
  );

  blocTest<FinanceCubit, FinanceState>(
    'filter and search changes preserve the paid set',
    build: FinanceCubit.new,
    act: (cubit) {
      cubit.markPaid('kid-01');
      cubit.search('leo');
      cubit.setPenaltyFilter(PenaltyFilter.unpaid);
    },
    verify: (cubit) {
      expect(cubit.state.paidKidIds, contains('kid-01'));
      expect(cubit.state.searchQuery, 'leo');
      expect(cubit.state.penaltyFilter, PenaltyFilter.unpaid);
    },
  );
}
