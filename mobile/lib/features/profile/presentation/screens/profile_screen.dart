import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/location_map_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/support_options_card.dart'; // الملف الجديد
import '../widgets/support_section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.darkGreen, size: 24.w),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Profile',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHeaderCard(),
                  SizedBox(height: 32.h),

                  // عنوان قسم الدعم
                  const SupportSectionHeader(),
                  SizedBox(height: 16.h),

                  // الكارت الأبيض الجديد اللي جواه الـ 3 اختيارات
                  const SupportOptionsCard(),

                  SizedBox(height: 24.h),

                  // كارت الخريطة المحدث
                  const LocationMapCard(),

                  SizedBox(height: 40.h),
                  const LogoutButton(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}