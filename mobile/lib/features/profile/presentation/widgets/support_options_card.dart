import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'support_list_tile.dart';

class SupportOptionsCard extends StatelessWidget {
  const SupportOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // مسافات داخلية للكارت
      padding: EdgeInsets.only(top: 24.h, left: 20.w, right: 20.w, bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          SupportListTile(
            icon: Icons.phone_in_talk_outlined,
            title: 'Call Us',
            subtitle: 'Immediate assistance for emergencies',
          ),
          SupportListTile(
            icon: Icons.chat_bubble_outline,
            title: 'WhatsApp Manager',
            subtitle: 'Quick text updates with the team',
          ),
          SupportListTile(
            icon: Icons.access_time,
            title: 'Working Hours',
            subtitle: '6:30am - 7:00pm (Mon - Fri)',
            trailingIcon: Icons.info_outline,
          ),
        ],
      ),
    );
  }
}