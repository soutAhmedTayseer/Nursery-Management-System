import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/finance_model.dart';

class PaymentTableRow extends StatelessWidget {
  final PaymentRecord record;
  const PaymentTableRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool hasPenalty = record.penaltyAmount > 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: hasPenalty ? const Color(0xFFFDF2E9) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: hasPenalty ? Border(left: BorderSide(color: Colors.orange, width: 4.w)) : null,
      ),
      child: Row(
        children: [
          _buildCell(2, Row(children: [
            CircleAvatar(
              radius: 16.r, 
              backgroundColor: record.avatarColor, 
              child: Text(
                record.parentName[0], 
                style: TextStyle(fontSize: 10.sp)
              )
            ),
            SizedBox(width: 12.w),
            Text(
              record.parentName, 
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)
            ),
          ])),
          _buildCell(1.5, Text(
            record.childName, 
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)
          )),
          _buildCell(1.5, Text(
            '${record.baseFee.toInt()} AED', 
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)
          )),
          _buildCell(1.5, Text(
            '${record.overtimeHours} hrs', 
            style: TextStyle(
              fontSize: 13.sp, 
              color: hasPenalty ? Colors.orange.shade700 : Colors.black
            )
          )),
          _buildCell(1.5, Text(
            '${record.penaltyAmount.toInt()} AED', 
            style: TextStyle(
              fontSize: 13.sp, 
              color: hasPenalty ? Colors.orange.shade700 : Colors.black
            )
          )),
          _buildCell(1.5, Text(
            '${record.totalDue.toInt()} AED', 
            style: TextStyle(
              fontSize: 14.sp, 
              fontWeight: FontWeight.w900, 
              color: hasPenalty ? Colors.black : const Color(0xFF386A41)
            )
          )),
          _buildCell(1, _buildExportBtn()),
        ],
      ),
    );
  }

  Widget _buildCell(double flex, Widget child) => Expanded(
    flex: (flex * 100).toInt(), 
    child: child
  );

  Widget _buildExportBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200), 
        borderRadius: BorderRadius.circular(20.r)
      ),
      child: Center(
        child: Text(
          'Export Invoice', 
          style: TextStyle(
            fontSize: 10.sp, 
            color: Colors.grey, 
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }
}
