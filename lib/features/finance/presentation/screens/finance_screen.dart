import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/testing/attendance_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_collection.dart';
import '../utils/settle_invoice.dart';
import '../../../subscriptions/data/models/plan_assignment.dart';
import '../../../subscriptions/data/models/subscription_plan.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_cubit.dart';
import '../../../subscriptions/presentation/cubit/plan_assignments_state.dart';
import '../../../subscriptions/presentation/cubit/plans_cubit.dart';
import '../../../subscriptions/presentation/cubit/plans_state.dart';
import '../../../settings/presentation/cubit/app_settings_cubit.dart';
import '../../data/models/finance_model.dart';
import '../../domain/payment_records.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../widgets/audit_log_dialog.dart';
import '../widgets/finance_stat_card.dart';
import '../utils/invoice_whatsapp.dart';
import '../widgets/payment_card.dart';
import '../widgets/revenue_chart.dart';
import '../../../../core/theme/app_palette.dart';

List<PaymentRecord> _filterRecords(List<PaymentRecord> records, String query, PenaltyFilter penaltyFilter) {
  return records.where((p) {
    final matchesQuery = query.isEmpty ||
        p.parentName.toLowerCase().contains(query.toLowerCase()) ||
        p.childName.toLowerCase().contains(query.toLowerCase());
    final matchesPenalty = switch (penaltyFilter) {
      PenaltyFilter.all => true,
      PenaltyFilter.withPenalty => p.penaltyAmount > 0,
      PenaltyFilter.withoutPenalty => p.penaltyAmount == 0,
      PenaltyFilter.unpaid => !p.isPaid,
      PenaltyFilter.paid => p.isPaid,
    };
    return matchesQuery && matchesPenalty;
  }).toList();
}

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FinanceCubit/PlansCubit/PlanAssignmentsCubit are all provided at the
    // app root (bootstrap.dart) so Finance and the dashboard read the same
    // shared instances — no local BlocProvider needed here.
    return BlocBuilder<PlanAssignmentsCubit, PlanAssignmentsState>(
      builder: (context, assignments) => BlocBuilder<PlansCubit, PlansState>(
        builder: (context, plans) => BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, finance) {
            final records = derivePaymentRecords(
              assignments,
              plans,
              finance,
              overtimeRate: context.watch<AppSettingsCubit>().state.overtimeHourlyRate,
            );
            final filtered = _filterRecords(records, finance.searchQuery, finance.penaltyFilter);
            return _buildScaffold(context, records, filtered, assignments, plans);
          },
        ),
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

  Widget _buildScaffold(
    BuildContext context,
    List<PaymentRecord> records,
    List<PaymentRecord> filtered,
    PlanAssignmentsState assignments,
    PlansState plans,
  ) {
  final palette = context.palette;
    final spacing = AppSpacing.of(context);
    // Settled invoices drop out of "outstanding" — that's the whole point
    // of marking them paid.
    final totalOutstanding = records.fold<double>(0, (sum, r) => sum + r.outstanding);
    final penaltyRevenue = records.fold<double>(0, (sum, r) => sum + r.penaltyAmount + r.overtimeAmount);
    final totalOutstandingCard = FinanceStatCard(
      title: 'finance_total_outstanding_title'.tr(),
      value: totalOutstanding.toStringAsFixed(0),
      subtitle: 'finance_total_outstanding_subtitle'.tr(),
      color: AppColors.forestGreen,
      trendWidget: _buildTrendBadge(context),
      watermarkIcon: Icons.eco,
    );
    final penaltyRevenueCard = FinanceStatCard(
      title: 'finance_penalty_revenue_title'.tr(),
      value: penaltyRevenue.toStringAsFixed(0),
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
          color: palette.card,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: RevenueChart(assignments: assignments, plans: plans, chartHeight: 200),
      ),
    );

    return Scaffold(
      backgroundColor: palette.page,
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
            _buildTableActions(context, filtered),
            SizedBox(height: spacing.md),

            // 3. Payments - table on desktop, cards below
            AdaptiveCollection<PaymentRecord>(
              items: filtered,
              rowBackgroundColor: (r) => r.isPaid
                  ? AppColors.successGreen.withValues(alpha: 0.06)
                  : r.penaltyAmount > 0
                  ? AppColors.penaltyOrange.withValues(alpha: 0.08)
                  : null,
              rowBorderColor: (r) => r.isPaid
                  ? AppColors.successGreen
                  : r.penaltyAmount > 0
                  ? AppColors.penaltyOrange
                  : null,
              columns: [
                AdaptiveColumn(label: 'finance_header_parent_name'.tr(), cell: (r) => Text(r.parentName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
                AdaptiveColumn(label: 'finance_header_child_name'.tr(), cell: (r) => Text(r.childName, style: TextStyle(fontSize: 13.sp, color: palette.textSecondary))),
                AdaptiveColumn(
                  label: 'finance_header_base_fee'.tr(),
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => Text('${r.baseFee.toInt()} AED', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
                AdaptiveColumn(
                  label: 'finance_header_overtime_hours'.tr(),
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${r.overtimeHours.toStringAsFixed(1)} hrs', style: TextStyle(fontSize: 13.sp)),
                      if (r.overtimeHours > 0)
                        Text('${r.overtimeAmount.toInt()} AED', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: palette.warningText)),
                    ],
                  ),
                ),
                AdaptiveColumn(
                  label: 'finance_header_penalty_amount'.tr(),
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => Text('${r.penaltyAmount.toInt()} AED', style: TextStyle(fontSize: 13.sp)),
                ),
                AdaptiveColumn(
                  label: 'finance_header_total_due'.tr(),
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => Text('${r.totalDue.toInt()} AED', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900)),
                ),
                AdaptiveColumn(
                  label: 'finance_header_status'.tr(),
                  width: 104.w,
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => _buildPaidToggle(context, r),
                ),
                AdaptiveColumn(
                  label: 'finance_header_action'.tr(),
                  width: 128.w,
                  align: AdaptiveColumnAlign.center,
                  cell: (r) => _buildInvoiceBtn(context, r),
                ),
              ],
              cardBuilder: (context, record) => PaymentCard(record: record),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(BuildContext context) {
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

  /// Settles an invoice. Paid rows drop out of the nursery's outstanding
  /// total, and the action is one-way — so it confirms first, then writes an
  /// audit entry naming who did it. An already-paid chip is inert.
  Widget _buildPaidToggle(BuildContext context, PaymentRecord record) {
    final color = record.isPaid ? AppColors.successGreen : AppColors.penaltyOrange;
    final chip = Container(
      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(record.isPaid ? Icons.lock : Icons.schedule, size: 12.w, color: color),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              record.isPaid ? 'finance_status_paid'.tr() : 'finance_status_unpaid'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (record.isPaid) {
      return Tooltip(message: 'finance_paid_locked_tooltip'.tr(), child: chip);
    }
    return InkWell(
      onTap: () => _confirmMarkPaid(context, record),
      borderRadius: BorderRadius.circular(999),
      child: chip,
    );
  }

  Future<void> _confirmMarkPaid(BuildContext context, PaymentRecord record) {
    return settleInvoice(
      context,
      kidId: record.id,
      childName: record.childName,
      amount: record.totalDue,
    );
  }

  /// Sends the invoice to the child's parent over WhatsApp, using the phone
  /// number on their plan assignment — the WhatsApp mark and tint make that
  /// destination obvious before the admin taps.
  Widget _buildInvoiceBtn(BuildContext context, PaymentRecord record) {
    return Tooltip(
      message: 'finance_invoice_whatsapp_tooltip'.tr(namedArgs: {'phone': record.parentPhone}),
      child: InkWell(
        onTap: () => sendInvoiceViaWhatsapp(context, record),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.whatsappGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.whatsappGreen.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_rounded, size: 14.w, color: AppColors.whatsappGreen),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'finance_export_invoice_table'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.whatsappGreen, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableActions(BuildContext context, List<PaymentRecord> filtered) {
  final palette = context.palette;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('finance_pending_title'.tr(), style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)),
        Text('finance_pending_subtitle'.tr(), style: TextStyle(fontSize: 13.sp, color: palette.textTertiary)),
      ],
    );
    final actions = Wrap(
      alignment: WrapAlignment.end,
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        _buildFilterBtn(context),
        _buildActionBtn(
          Icons.file_download_outlined,
          'finance_batch_export'.tr(),
          AppColors.forestGreen,
          Colors.white,
          onTap: () => _exportPayments(context, filtered),
        ),
        _buildActionBtn(
          Icons.history,
          'audit_log_open'.tr(),
          context.palette.chip,
          context.palette.textPrimary,
          onTap: () => AuditLogDialog.show(context),
        ),
        _buildActionBtn(
          Icons.receipt_long_outlined,
          'finance_add_invoice'.tr(),
          AppColors.darkGreen,
          Colors.white,
          onTap: () => _showAddInvoiceDialog(context),
        ),
      ],
    );
    // Always right-docked: on a wide screen title+actions share one row; on
    // a narrow one they stack, but the actions row is explicitly
    // right-aligned rather than left-aligned like an ordinary wrapped Wrap
    // child would default to.
    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, SizedBox(height: 12.h), Align(alignment: Alignment.centerRight, child: actions)],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [title, const Spacer(), actions],
    );
  }

  Widget _buildFilterBtn(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final isActive = state.penaltyFilter != PenaltyFilter.all;
        final palette = context.palette;
        return PopupMenuButton<PenaltyFilter>(
          onSelected: (filter) => context.read<FinanceCubit>().setPenaltyFilter(filter),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          itemBuilder: (context) => [
            PopupMenuItem(value: PenaltyFilter.all, child: Text('finance_filter_all'.tr())),
            PopupMenuItem(value: PenaltyFilter.unpaid, child: Text('finance_filter_unpaid'.tr())),
            PopupMenuItem(value: PenaltyFilter.paid, child: Text('finance_filter_paid'.tr())),
            PopupMenuItem(value: PenaltyFilter.withPenalty, child: Text('finance_filter_with_penalty'.tr())),
            PopupMenuItem(value: PenaltyFilter.withoutPenalty, child: Text('finance_filter_without_penalty'.tr())),
          ],
          child: _actionBtnDecoration(
            Icons.filter_list,
            'finance_filter'.tr(),
            isActive ? AppColors.penaltyOrange : palette.chip,
            isActive ? Colors.white : palette.textPrimary,
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

  Future<void> _exportPayments(BuildContext context, List<PaymentRecord> payments) async {
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

  /// Hours the child stayed past their plan this month, read from the
  /// shared attendance ledger — the same figure their calendar's red days
  /// add up to. A "Full Day" plan (null hoursPerDay) can't accrue overtime.
  double _computeOvertimeHours(String kidId, PlanLineItem item) =>
      overtimeHoursForMonth(kidId, item.hoursPerDay, DateTime.now());

  /// Adds an invoice (overtime auto-computed from attendance, penalty
  /// manual) for a child picked from the sessions roster — their current
  /// assigned plan/price auto-fill from PlanAssignmentsCubit/PlansCubit.
  /// "Add" writes straight into FinanceCubit's extras, which
  /// derivePaymentRecords folds into the payments/overtime table.
  void _showAddInvoiceDialog(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<FinanceCubit>();
    final plansCubit = context.read<PlansCubit>();
    final assignments = context.read<PlanAssignmentsCubit>().state.byKidId.values.toList();
    final penaltyCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    PlanAssignment? selected = assignments.isEmpty ? null : assignments.first;
    late TextEditingController overtimeCtrl;

    (PlanCategory, PlanLineItem)? lineItemFor(PlanAssignment? assignment) =>
        assignment == null ? null : plansCubit.findLineItem(assignment.categoryId, assignment.lineItemId);

    final initialItem = lineItemFor(selected);
    overtimeCtrl = TextEditingController(
      text: initialItem == null ? '0' : _computeOvertimeHours(selected!.kidId, initialItem.$2).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final item = lineItemFor(selected);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            title: Text('finance_add_invoice'.tr(), style: TextStyle(fontWeight: FontWeight.w900)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (assignments.isEmpty)
                      Text('finance_no_assigned_children'.tr())
                    else
                      DropdownButtonFormField<PlanAssignment>(
                        initialValue: selected,
                        decoration: InputDecoration(
                          labelText: 'finance_dialog_child_label'.tr(),
                          filled: true,
                          fillColor: palette.divider,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                        ),
                        items: [
                          for (final a in assignments)
                            DropdownMenuItem(value: a, child: Text('${a.kidName} (${a.parentName})')),
                        ],
                        onChanged: (value) => setDialogState(() {
                          selected = value;
                          final newItem = lineItemFor(value);
                          overtimeCtrl.text = newItem == null ? '0' : _computeOvertimeHours(value!.kidId, newItem.$2).toStringAsFixed(1);
                        }),
                      ),
                    if (item != null) ...[
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${item.$2.label} · ${item.$2.price}',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: palette.brandText),
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _dialogField(context, overtimeCtrl, 'finance_header_overtime_hours'.tr(), isNumber: true),
                    if (item != null && selected != null) ...[
                      SizedBox(height: 6.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'finance_overtime_auto_note'.tr(namedArgs: {
                            'days': '${AttendanceStore.instance.forMonth(selected!.kidId, DateTime.now()).where((r) => r.overtimeHours(item.$2.hoursPerDay) > 0).length}',
                          }),
                          style: TextStyle(fontSize: 11.sp, color: palette.textSecondary),
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _dialogField(context, penaltyCtrl, 'finance_header_penalty_amount'.tr(), isNumber: true),
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
                onPressed: selected == null
                    ? null
                    : () {
                        if (!formKey.currentState!.validate()) return;
                        // Only record an override when the admin actually
                        // changed the figure — otherwise leave overtime
                        // tracking the attendance ledger so it keeps
                        // updating as the child clocks in and out.
                        final typed = double.tryParse(overtimeCtrl.text) ?? 0;
                        final computed = item == null ? 0.0 : _computeOvertimeHours(selected!.kidId, item.$2);
                        cubit.setExtras(
                          selected!.kidId,
                          overtimeHours: (typed - computed).abs() < 0.05 ? null : typed,
                          penaltyAmount: double.tryParse(penaltyCtrl.text) ?? 0,
                        );
                        Navigator.pop(dialogContext);
                      },
                child: Text('finance_add_button'.tr(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField(BuildContext context, TextEditingController controller, String label, {bool isNumber = false, bool isRequired = true}) {

  final palette = context.palette;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: isRequired ? (value) => (value == null || value.trim().isEmpty) ? '' : null : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: palette.divider,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
    );
  }
}
