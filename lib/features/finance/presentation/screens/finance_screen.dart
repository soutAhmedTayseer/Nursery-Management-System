import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
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
import '../utils/invoice_whatsapp.dart';
import '../widgets/payment_card.dart';
import '../widgets/revenue_chart.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinanceCubit(),
      // `context` above this point is FinanceScreen's own Element, which sits
      // ABOVE this BlocProvider — reading FinanceCubit with it throws
      // ProviderNotFoundError. `Builder` re-enters the tree just below the
      // provider so every descendant context here can see it.
      child: Builder(
        builder: (context) => _buildScaffold(context),
      ),
    );
  }

  // Stable across rebuilds (StatelessWidget field, not a local in
  // _buildScaffold) so the same GlobalKey identity survives every build —
  // that's what lets Flutter *move* these subtrees between the portrait
  // Column and the landscape IntrinsicHeight/Row layouts below instead of
  // destroying and recreating them. See _buildScaffold for why that matters.
  static final _chartKey = GlobalKey();
  static final _statsKey = GlobalKey();

  Widget _buildScaffold(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final totalOutstandingCard = FinanceStatCard(
      title: 'finance_total_outstanding_title'.tr(),
      value: '42,850',
      subtitle: 'finance_total_outstanding_subtitle'.tr(),
      color: AppColors.forestGreen,
      trendWidget: _buildTrendBadge(),
    );
    final penaltyRevenueCard = FinanceStatCard(
      title: 'finance_penalty_revenue_title'.tr(),
      value: '3,125',
      subtitle: 'finance_penalty_revenue_subtitle'.tr(),
      color: AppColors.penaltyOrange,
    );
    // The layout below swaps between a plain `Column` (portrait) and an
    // `IntrinsicHeight`-wrapped `Row` (landscape) — two structurally
    // different widget types at the same tree slot. Without a stable key,
    // crossing that breakpoint destroys and remounts everything under it,
    // including `RevenueChart`'s InkWells (period pills). Tearing those
    // down mid-frame is exactly what desyncs Flutter's MouseTracker
    // ('!_debugDuringDeviceUpdate') and produces "never laid out" hit-test
    // crashes — the same bug class already fixed once for the admin
    // sidebar. `KeyedSubtree` + a stable `GlobalKey` tells Flutter to
    // relocate the existing element/state instead of rebuilding from
    // scratch, so the swap survives.
    final statsContent = KeyedSubtree(
      key: _statsKey,
      child: context.isCompact
          // `Row` here is a non-flex child of the outer portrait `Column`,
          // which hands non-flex children an UNBOUNDED height. `stretch`
          // then tries to stretch the `Expanded` cards to that unbounded
          // height — an infinite-height constraint that crashes layout on
          // every frame and silently kills everything painted after it.
          // `IntrinsicHeight` measures a real, bounded height for the Row
          // first (same trick the landscape Row below already relies on).
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: totalOutstandingCard),
                  SizedBox(width: spacing.md),
                  Expanded(child: penaltyRevenueCard),
                ],
              ),
            )
          : Column(
              children: [
                totalOutstandingCard,
                SizedBox(height: spacing.md),
                penaltyRevenueCard,
              ],
            ),
    );
    final chartCard = KeyedSubtree(
      key: _chartKey,
      child: Container(
        padding: EdgeInsets.all(spacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: const RevenueChart(chartHeight: 200),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceIvory,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.forestGreen,
        onPressed: () => _showAddPaymentDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
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
                  statsContent,
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: chartCard),
                    SizedBox(width: spacing.lg),
                    Expanded(flex: 1, child: statsContent),
                  ],
                ),
              ),
            SizedBox(height: spacing.xxl),

            // 2. Table Header and Actions
            _buildTableActions(context),
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
                    AdaptiveColumn(
                      label: 'finance_header_action'.tr(),
                      width: 140.w,
                      cell: (r) => _buildInvoiceBtn(context, r),
                    ),
                  ],
                  cardBuilder: (context, record) => PaymentCard(record: record),
                );
              },
            ),
          ],
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

  Widget _buildInvoiceBtn(BuildContext context, PaymentRecord record) {
    return InkWell(
      onTap: () => sendInvoiceViaWhatsapp(context, record),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(color: AppColors.whatsappGreen, borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_rounded, size: 13.w, color: Colors.white),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'finance_export_invoice'.tr(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12.h,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterBtn(context),
            SizedBox(width: 12.w),
            _buildActionBtn(
              Icons.file_download_outlined,
              'finance_batch_export'.tr(),
              AppColors.forestGreen,
              Colors.white,
              onTap: () => _exportPayments(context),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildFilterBtn(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final isActive = state.penaltyFilter != PenaltyFilter.all;
        return PopupMenuButton<PenaltyFilter>(
          onSelected: (filter) => context.read<FinanceCubit>().setPenaltyFilter(filter),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          itemBuilder: (context) => [
            PopupMenuItem(value: PenaltyFilter.all, child: Text('finance_filter_all'.tr())),
            PopupMenuItem(value: PenaltyFilter.withPenalty, child: Text('finance_filter_with_penalty'.tr())),
            PopupMenuItem(value: PenaltyFilter.withoutPenalty, child: Text('finance_filter_without_penalty'.tr())),
          ],
          child: _actionBtnDecoration(
            Icons.filter_list,
            'finance_filter'.tr(),
            isActive ? AppColors.penaltyOrange : Colors.grey.shade200,
            isActive ? Colors.white : Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color bg, Color text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: _actionBtnDecoration(icon, label, bg, text),
    );
  }

  Widget _actionBtnDecoration(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

  Future<void> _exportPayments(BuildContext context) async {
    final payments = context.read<FinanceCubit>().state.filteredPayments;
    final buffer = StringBuffer()
      ..writeln('Parent,Child,Base Fee (AED),Overtime Hours,Penalty (AED),Total Due (AED)');
    for (final p in payments) {
      buffer.writeln(
        '${_csvField(p.parentName)},${_csvField(p.childName)},${p.baseFee},${p.overtimeHours},${p.penaltyAmount},${p.totalDue}',
      );
    }
    final bytes = utf8.encode(buffer.toString());

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'finance_batch_export'.tr(),
      fileName: 'payments_export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );
    if (path == null || !context.mounted) return;

    // file_picker writes `bytes` for us on mobile/Linux; on Windows/macOS it
    // only returns the chosen path, so write it ourselves if still missing.
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsBytes(bytes);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('finance_export_started'.tr(namedArgs: {'count': '${payments.length}'}))),
    );
  }

  String _csvField(String value) {
    final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
    if (!needsQuoting) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  void _showAddPaymentDialog(BuildContext context) {
    final cubit = context.read<FinanceCubit>();
    final parentNameCtrl = TextEditingController();
    final childNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final baseFeeCtrl = TextEditingController();
    final overtimeCtrl = TextEditingController(text: '0');
    final penaltyCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text('finance_add_payment_title'.tr(), style: TextStyle(fontWeight: FontWeight.w900)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(parentNameCtrl, 'finance_header_parent_name'.tr()),
                SizedBox(height: 12.h),
                _dialogField(childNameCtrl, 'finance_header_child_name'.tr()),
                SizedBox(height: 12.h),
                _dialogField(phoneCtrl, 'finance_dialog_phone_label'.tr(), isNumber: true, isRequired: false),
                SizedBox(height: 12.h),
                _dialogField(baseFeeCtrl, 'finance_header_base_fee'.tr(), isNumber: true),
                SizedBox(height: 12.h),
                _dialogField(overtimeCtrl, 'finance_header_overtime_hours'.tr(), isNumber: true),
                SizedBox(height: 12.h),
                _dialogField(penaltyCtrl, 'finance_header_penalty_amount'.tr(), isNumber: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('finance_cancel_button'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              cubit.addPayment(PaymentRecord(
                id: DateTime.now().toString(),
                parentName: parentNameCtrl.text.trim(),
                childName: childNameCtrl.text.trim(),
                baseFee: double.tryParse(baseFeeCtrl.text) ?? 0,
                overtimeHours: double.tryParse(overtimeCtrl.text) ?? 0,
                penaltyAmount: double.tryParse(penaltyCtrl.text) ?? 0,
                avatarColor: Colors.blue.shade100,
                parentPhone: phoneCtrl.text.trim(),
              ));
              Navigator.pop(dialogContext);
            },
            child: Text('finance_add_button'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, {bool isNumber = false, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: isRequired ? (value) => (value == null || value.trim().isEmpty) ? '' : null : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceSmoke,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
    );
  }
}
