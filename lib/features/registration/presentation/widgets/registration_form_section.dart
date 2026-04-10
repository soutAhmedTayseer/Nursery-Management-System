import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  const RegistrationFormSection({
    super.key, required this.title, required this.icon, required this.accentColor, required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EC), // Off-white/beige color for cards
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: accentColor.withOpacity(0.1),
                child: Icon(icon, color: accentColor, size: 18.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp, 
                    fontWeight: FontWeight.w900, 
                    color: accentColor, 
                    letterSpacing: 1.2
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          ...children,
        ],
      ),
    );
  }
}
