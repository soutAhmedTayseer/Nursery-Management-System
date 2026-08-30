import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/plans_cubit.dart';
import '../widgets/daily_plan_tile.dart';
import '../widgets/monthly_plan_card.dart';
import '../widgets/special_offer_card.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlansCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.darkGreen, size: 24.w),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Subscriptions & Offers', style: TextStyle(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // شيلنا الـ padding الأفقي من هنا عشان السكرول الأفقي ياخد الشاشة كلها
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Monthly Fees
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Monthly Fees'),
                      const MonthlyPlanCard(title: '3 hours / 3 DAYS', subtitle: 'Perfect for socialization', price: '600', isPopular: true),
                      const MonthlyPlanCard(title: '3 hours / 5 DAYS', subtitle: 'Daily routine building', price: '1000'),
                      const MonthlyPlanCard(title: '5 hours / 5 DAYS', subtitle: 'Full immersion experience', price: '1500'),
                      const MonthlyPlanCard(title: '8 hours / 5 DAYS', subtitle: 'Extended care', price: '1750'),
                      const MonthlyPlanCard(title: 'Full Day / 5 DAYS', subtitle: 'Complete coverage', price: '2000'),
                      SizedBox(height: 16.h),

                      // 2. Daily Subscription Fees
                      _buildSectionTitle('Daily Subscription Fees'),
                      const DailyPlanTile(icon: Icons.schedule, title: 'One hour', subtitle: 'Quick session', price: '35'),
                      const DailyPlanTile(icon: Icons.timer, title: '2/3 hours', subtitle: 'Flexible morning', price: '70'),
                      const DailyPlanTile(icon: Icons.wb_sunny_outlined, title: 'Full Day', subtitle: 'All activities included', price: '150'),
                      SizedBox(height: 16.h),

                      _buildSectionTitle('Special Offers/Camps'),
                    ],
                  ),
                ),

                // 3. Special Offers (Horizontal Scroll - Carousel)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(), // أنيميشن السحب الناعم
                  padding: EdgeInsets.symmetric(horizontal: 24.w), // بادينج داخلي للسكرول
                  child: Row(
                    children: [
                      const SpecialOfferCard(
                        badgeText: 'LIMITED TIME',
                        title: 'Weekend Offer: 5 Hours',
                        price: '50 AED',
                        bgColor: Color(0xFFFFE0B2), // Peach
                        bgIcon: Icons.weekend_outlined, // أيقونة الكنبة
                      ),
                      SizedBox(width: 16.w),
                      const SpecialOfferCard(
                        badgeText: 'SEASONAL',
                        title: 'Winter Camp',
                        price: '900\nAED/Week', // السعر على سطرين زي الصورة
                        bgColor: Color(0xFFFFECCC), // Light Orange
                        bgIcon: Icons.ac_unit, // أيقونة ندفة الثلج
                      ),
                      SizedBox(width: 16.w), // مساحة إضافية في الآخر للسكرول
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 4. Notes
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Center(
                    child: Text(
                      'Note: Overtime hours will be charged automatically based on daily rates (35 AED/h).\nWorking hours: 6:30 am - 7:00 pm Everyday.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
      child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }
}