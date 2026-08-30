import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const EditProfileDialog({super.key, required this.currentName, required this.currentEmail});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
    phoneController = TextEditingController(text: "+971 50 000 0000"); // قيمة مبدئية
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Profile', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 24.h),

            // Profile Picture Section with Camera Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: const AssetImage('assets/images/parent_avatar_placeholder.png'),
                ),
                GestureDetector(
                  onTap: () {
                    // Logic to open Camera / Gallery goes here
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: AppColors.darkGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 16.w),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Input Fields
            _buildTextField('Full Name', nameController, Icons.person_outline),
            SizedBox(height: 16.h),
            _buildTextField('Email Address', emailController, Icons.email_outlined),
            SizedBox(height: 16.h),
            _buildTextField('Mobile Number', phoneController, Icons.phone_outlined),
            SizedBox(height: 32.h),

            // Action Buttons
            BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state is ProfileEditSuccess) {
                  Navigator.pop(context); // إغلاق الـ Dialog عند النجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                  );
                }
              },
              builder: (context, state) {
                bool isLoading = state is ProfileEditLoading;

                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          context.read<ProfileCubit>().updateProfile(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: isLoading
                            ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Save', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Custom TextField Builder for the Dialog
  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: AppColors.darkGreen, size: 20.w),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.darkGreen)),
      ),
    );
  }
}