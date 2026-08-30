import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class ExpandableSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  State<ExpandableSectionCard> createState() => _ExpandableSectionCardState();
}

class _ExpandableSectionCardState extends State<ExpandableSectionCard> {
  bool isExpanded = true; // مفتوح افتراضياً زي الديزاين

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Header (Clickable)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(widget.icon, color: Colors.orange.shade800, size: 20.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                SizedBox(height: 20.h),
                widget.content,
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}