import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import 'edit_profile_dialog.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = 'Elena Rodriguez';
    String userEmail = 'elena.rod@example.com';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: EditProfileDialog(currentName: userName, currentEmail: userEmail),
                ),
              );
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 35.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: const AssetImage('assets/images/parent_avatar_placeholder.png'),
                  child: Icon(Icons.person, size: 40.w, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(color: AppColors.darkGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: Icon(Icons.edit, color: Colors.white, size: 12.w),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 4.h),
                Text(userEmail, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: AppColors.darkGreen, size: 12.w),
                      SizedBox(width: 4.w),
                      Text('VERIFIED PARENT', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}