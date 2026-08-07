import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/responsive/ui_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp.dart';
import '../../../finance/presentation/utils/settle_invoice.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
import '../../domain/nursery_alerts.dart';
import '../../../../core/theme/app_palette.dart';

/// Dashboard alert feed. Every card is derived from real state (live
/// attendance, unpaid invoices) and every button does something: message
/// the parent on WhatsApp, check the child out, or settle the invoice.
class AlertsNotificationsSection extends StatelessWidget {
  const AlertsNotificationsSection({super.key, required this.alerts});

  final List<NurseryAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.uiScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header — stays put; only the content below scrolls.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('alerts_header_title'.tr(), style: TextStyle(fontSize: (22 * scale).sp, fontWeight: FontWeight.bold, color: palette.textPrimary)),
            if (alerts.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.dangerRed.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '${alerts.length}',
                  style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.w900, color: AppColors.dangerRed),
                ),
              ),
          ],
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: alerts.isEmpty
              ? Center(child: Text('alerts_empty'.tr(), style: TextStyle(fontSize: (13 * scale).sp, color: palette.textTertiary)))
              : ListView.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) => _AlertCard(alert: alerts[index], scale: scale),
                ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.scale});

  final NurseryAlert alert;
  final double scale;

  ({String title, String description, IconData icon, Color color}) get _presentation {
    switch (alert.kind) {
      case AlertKind.overtimeLive:
        return (
          title: 'alerts_overtime_title'.tr(namedArgs: {'name': alert.kidName}),
          description: 'alerts_overtime_desc'.tr(namedArgs: {'hours': alert.hours.toStringAsFixed(1)}),
          icon: Icons.warning_amber_rounded,
          color: AppColors.dangerRed,
        );
      case AlertKind.lateCheckout:
        return (
          title: 'alerts_late_checkout_title'.tr(namedArgs: {'name': alert.kidName}),
          description: 'alerts_late_checkout_desc'.tr(namedArgs: {'hours': alert.hours.toStringAsFixed(1)}),
          icon: Icons.nightlight_round,
          color: AppColors.penaltyOrange,
        );
      case AlertKind.overtimeBillable:
        return (
          title: 'alerts_overtime_billable_title'.tr(namedArgs: {'name': alert.kidName}),
          description: 'alerts_overtime_billable_desc'.tr(namedArgs: {
            'hours': alert.hours.toStringAsFixed(1),
            'amount': alert.amount.toInt().toString(),
          }),
          icon: Icons.more_time_rounded,
          color: AppColors.brownLight,
        );
      case AlertKind.paymentDue:
        return (
          title: 'alerts_payment_due_title'.tr(namedArgs: {'name': alert.kidName}),
          description: 'alerts_payment_due_desc'.tr(namedArgs: {'amount': alert.amount.toInt().toString()}),
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.amberLabel,
        );
    }
  }

  String get _whatsappMessage {
    switch (alert.kind) {
      case AlertKind.overtimeLive:
      case AlertKind.lateCheckout:
        return 'alerts_whatsapp_pickup'.tr(namedArgs: {'parent': alert.parentName, 'child': alert.kidName});
      case AlertKind.overtimeBillable:
      case AlertKind.paymentDue:
        return 'alerts_whatsapp_payment'.tr(namedArgs: {
          'parent': alert.parentName,
          'child': alert.kidName,
          'amount': alert.amount.toInt().toString(),
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final look = _presentation;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: look.color,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), bottomLeft: Radius.circular(24.r)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(look.icon, color: look.color, size: (24 * scale).w),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  look.title,
                                  style: TextStyle(fontSize: (16 * scale).sp, fontWeight: FontWeight.bold, color: palette.textPrimary),
                                ),
                              ),
                              if (alert.isUrgent)
                                Text(
                                  'alerts_urgent_badge'.tr(),
                                  style: TextStyle(fontSize: (10 * scale).sp, fontWeight: FontWeight.bold, color: look.color, letterSpacing: 1),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(look.description, style: TextStyle(fontSize: (13 * scale).sp, color: palette.textSecondary, height: 1.5)),
                          SizedBox(height: 16.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 8.h,
                            children: _actions(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      _button(
        'alerts_message_parent'.tr(),
        isPrimary: true,
        icon: Icons.chat_bubble_rounded,
        onTap: () => openWhatsappChat(context, phone: alert.parentPhone, message: _whatsappMessage),
      ),
      if (alert.kind == AlertKind.overtimeLive || alert.kind == AlertKind.lateCheckout)
        _button(
          'alerts_check_out'.tr(),
          isPrimary: false,
          icon: Icons.logout,
          onTap: () => context.read<SessionsCubit>().clockOut(alert.kidId),
        ),
      if (alert.kind == AlertKind.paymentDue || alert.kind == AlertKind.overtimeBillable)
        _button(
          'alerts_mark_paid'.tr(),
          isPrimary: false,
          icon: Icons.check_circle_outline,
          onTap: () => settleInvoice(
            context,
            kidId: alert.kidId,
            childName: alert.kidName,
            amount: alert.amount,
          ),
        ),
    ];
  }

  Widget _button(String text, {required bool isPrimary, required IconData icon, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: (14 * scale).w, color: isPrimary ? Colors.white : AppColors.brown),
      label: Text(
        text,
        style: TextStyle(fontSize: (12 * scale).sp, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : AppColors.brown),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.brown : Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.brown, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h * scale),
      ),
    );
  }
}
