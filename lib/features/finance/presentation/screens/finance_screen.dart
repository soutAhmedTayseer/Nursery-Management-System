import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_collection.dart';
import '../../data/models/finance_model.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../widgets/finance_stat_card.dart';
import '../widgets/payment_table_row.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final statsColumn = Column(
      children: [
        FinanceStatCard(
          title: 'finance_total_outstanding_title'.tr(),
          value: '42,850',
          subtitle: 'finance_total_outstanding_subtitle'.tr(),
          color: AppColors.forestGreen,
          trendWidget: _buildTrendBadge(),
        ),
        SizedBox(height: spacing.md),
        FinanceStatCard(
          title: 'finance_penalty_revenue_title'.tr(),
          value: '3,125',
          subtitle: 'finance_penalty_revenue_subtitle'.tr(),
          color: AppColors.peachTint.withValues(alpha: 0.8),
        ),
      ],
    );
    final chartCard = Container(
      padding: EdgeInsets.all(spacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: _buildRevenueHeader(),
    );

    return BlocProvider(
      create: (context) => FinanceCubit(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceIvory,
        floatingActionButton: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            return FloatingActionButton(
              backgroundColor: AppColors.forestGreen,
              onPressed: () => _showAddPaymentDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Section: Charts and Stats - stacks at compact
              if (context.isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chartCard,
                    SizedBox(height: spacing.md),
                    statsColumn,
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: chartCard),
                      SizedBox(width: spacing.lg),
                      Expanded(flex: 1, child: statsColumn),
                    ],
                  ),
                ),
              SizedBox(height: spacing.xxl),

              // 2. Table Header and Actions
              _buildTableActions(),
              SizedBox(height: spacing.md),

              // 3. Payments - table on desktop, cards below
              BlocBuilder<FinanceCubit, FinanceState>(
                builder: (context, state) {
                  return AdaptiveCollection<PaymentRecord>(
                    items: state.filteredPayments,
                    columns: [
                      AdaptiveColumn(label: 'finance_header_parent_name'.tr(), cell: (r) => Text(r.parentName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
                      AdaptiveColumn(label: 'finance_header_child_name'.tr(), cell: (r) => Text(r.childName, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600))),
                      AdaptiveColumn(label: 'finance_header_base_fee'.tr(), cell: (r) => Text('${r.baseFee.toInt()} AED', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
                      AdaptiveColumn(label: 'finance_header_overtime_hours'.tr(), cell: (r) => Text('${r.overtimeHours} hrs', style: TextStyle(fontSize: 13.sp))),
                      AdaptiveColumn(label: 'finance_header_penalty_amount'.tr(), cell: (r) => Text('${r.penaltyAmount.toInt()} AED', style: TextStyle(fontSize: 13.sp))),
                      AdaptiveColumn(label: 'finance_header_total_due'.tr(), cell: (r) => Text('${r.totalDue.toInt()} AED', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900))),
                    ],
                    cardBuilder: (context, record) => PaymentTableRow(record: record),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white24, 
        borderRadius: BorderRadius.circular(8.r)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, color: Colors.white, size: 12.w),
          SizedBox(width: 4.w),
          Text(
            'finance_trend_vs_last_month'.tr(),
            style: TextStyle(
              color: Colors.white, 
              fontSize: 10.sp, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  Widget _buildTableActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'finance_pending_title'.tr(),
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)
            ),
            Text(
              'finance_pending_subtitle'.tr(),
              style: TextStyle(fontSize: 13.sp, color: Colors.grey)
            ),
          ],
        ),
        Row(
          children: [
            _buildActionBtn(
              Icons.filter_list,
              'finance_filter'.tr(),
              Colors.grey.shade200,
              Colors.black
            ),
            SizedBox(width: 12.w),
            _buildActionBtn(
              Icons.file_download_outlined,
              'finance_batch_export'.tr(),
              AppColors.forestGreen,
              Colors.white
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        children: [
          Icon(icon, size: 18.w, color: text), 
          SizedBox(width: 8.w), 
          Text(
            label, 
            style: TextStyle(
              color: text, 
              fontWeight: FontWeight.bold, 
              fontSize: 13.sp
            )
          )
        ]
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final cubit = context.read<FinanceCubit>();
    cubit.addPayment(PaymentRecord(
      id: DateTime.now().toString(),
      parentName: 'New Parent',
      childName: 'New Child',
      baseFee: 3000,
      overtimeHours: 1,
      penaltyAmount: 50,
      avatarColor: Colors.blue.shade100,
    ));
  }

  Widget _buildRevenueHeader() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'finance_revenue_title'.tr(),
           style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)
         ),
         Text(
           'finance_revenue_subtitle'.tr(),
           style: TextStyle(fontSize: 12.sp, color: Colors.grey)
         ),
         const Spacer(),
         Center(child: Text('finance_chart_placeholder'.tr())),
         const Spacer(),
       ],
     );
  }
}
