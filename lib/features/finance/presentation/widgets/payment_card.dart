import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/finance_model.dart';
import '../utils/invoice_whatsapp.dart';
import '../utils/settle_invoice.dart';

/// Stacked payment layout for narrow (portrait/tablet) widths.
///
/// [PaymentTableRow] is a dense 7-column flex row meant for the desktop
/// table — reusing it below `expanded` overflows badly on narrow screens
/// and effectively hides the payments list. This lays the same fields out
/// vertically so nothing needs to fit side by side.
class PaymentCard extends StatelessWidget {
  final PaymentRecord record;
  const PaymentCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final hasPenalty = record.penaltyAmount > 0;
    final statusColor = record.isPaid ? AppColors.successGreen : AppColors.penaltyOrange;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: hasPenalty ? AppColors.creamTint : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: hasPenalty ? Border.all(color: AppColors.penaltyOrange.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: record.avatarColor,
                child: Text(record.parentName[0], style: TextStyle(fontSize: 12.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.parentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text(record.childName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${record.totalDue.toInt()} AED',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: hasPenalty ? Colors.black : AppColors.forestGreen),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              _stat('finance_header_base_fee'.tr(), '${record.baseFee.toInt()} AED'),
              _stat(
                'finance_header_overtime_hours'.tr(),
                '${record.overtimeHours.toStringAsFixed(1)} hrs',
                color: record.overtimeHours > 0 ? AppColors.penaltyOrange : null,
              ),
              _stat('finance_header_penalty_amount'.tr(), '${record.penaltyAmount.toInt()} AED', color: hasPenalty ? AppColors.penaltyOrange : null),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  // Settling is one-way, so a paid card's chip is inert.
                  onTap: record.isPaid
                      ? null
                      : () => settleInvoice(
                            context,
                            kidId: record.id,
                            childName: record.childName,
                            amount: record.totalDue,
                          ),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(record.isPaid ? Icons.lock : Icons.schedule, size: 14.w, color: statusColor),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            record.isPaid ? 'finance_status_paid'.tr() : 'finance_status_unpaid'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.sp, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: InkWell(
                  onTap: () => sendInvoiceViaWhatsapp(context, record),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(color: AppColors.whatsappGreen, borderRadius: BorderRadius.circular(20.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_rounded, size: 14.w, color: Colors.white),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'finance_export_invoice'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 2.h),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
