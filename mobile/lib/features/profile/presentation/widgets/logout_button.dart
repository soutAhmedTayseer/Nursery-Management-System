import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_cubit.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          context.read<ProfileCubit>().logout();
        },
        icon: Icon(Icons.logout, color: Colors.grey.shade600, size: 20.w),
        label: Text(
          'Log Out',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}