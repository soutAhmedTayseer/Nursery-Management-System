import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/finance_model.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../widgets/finance_stat_card.dart';
import '../widgets/payment_table_row.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinanceCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        floatingActionButton: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            return FloatingActionButton(
              backgroundColor: const Color(0xFF386A41),
              onPressed: () => _showAddPaymentDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Section: Charts and Stats
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Revenue Breakdown Chart Card
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(32.r)
                        ),
                        child: _buildRevenueHeader(),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    // Stats Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(child: FinanceStatCard(
                            title: 'Total Outstanding', 
                            value: '42,850', 
                            subtitle: 'Total fees expected but not yet collected this month.', 
                            color: const Color(0xFF386A41),
                            trendWidget: _buildTrendBadge(),
                          )),
                          SizedBox(height: 16.h),
                          Expanded(child: FinanceStatCard(
                            title: 'Penalty Revenue', 
                            value: '3,125', 
                            subtitle: 'Total generated from overtime and late collection fees.', 
                            color: const Color(0xFFFFDBCF).withOpacity(0.8), // Adjusting for visibility
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),

              // 2. Table Header and Actions
              _buildTableActions(),
              SizedBox(height: 24.h),

              // 3. Payments Table
              _buildTableHeaderLabels(),
              SizedBox(height: 16.h),
              
              BlocBuilder<FinanceCubit, FinanceState>(
                builder: (context, state) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredPayments.length,
                    itemBuilder: (context, index) => PaymentTableRow(
                      record: state.filteredPayments[index]
                    ),
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
            '12% vs last month', 
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
              'Pending Payments & Overtime Penalty', 
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)
            ),
            Text(
              'Detailed list of accounts with pending balances and penalty assessments', 
              style: TextStyle(fontSize: 13.sp, color: Colors.grey)
            ),
          ],
        ),
        Row(
          children: [
            _buildActionBtn(
              Icons.filter_list, 
              'Filter', 
              Colors.grey.shade200, 
              Colors.black
            ),
            SizedBox(width: 12.w),
            _buildActionBtn(
              Icons.file_download_outlined, 
              'Batch Export', 
              const Color(0xFF386A41), 
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

  Widget _buildTableHeaderLabels() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildHeaderCell(2, 'PARENT NAME'),
          _buildHeaderCell(1.5, 'CHILD NAME'),
          _buildHeaderCell(1.5, 'BASE PLAN FEE'),
          _buildHeaderCell(1.5, 'OVERTIME HOURS'),
          _buildHeaderCell(1.5, 'PENALTY AMOUNT'),
          _buildHeaderCell(1.5, 'TOTAL DUE'),
          _buildHeaderCell(1, 'ACTION'),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(double flex, String text) => Expanded(
    flex: (flex * 100).toInt(), 
    child: Text(
      text, 
      style: TextStyle(
        fontSize: 10.sp, 
        fontWeight: FontWeight.bold, 
        color: Colors.grey.shade400, 
        letterSpacing: 1
      )
    )
  );
  
  Widget _buildRevenueHeader() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'Monthly Revenue Breakdown', 
           style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)
         ),
         Text(
           'Performance analytics for current billing cycle', 
           style: TextStyle(fontSize: 12.sp, color: Colors.grey)
         ),
         const Spacer(),
         const Center(child: Text("Chart Placeholder")),
         const Spacer(),
       ],
     );
  }
}
