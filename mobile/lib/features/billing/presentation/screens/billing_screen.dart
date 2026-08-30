import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

import '../cubit/billing_cubit.dart';
import '../cubit/billing_state.dart';
import '../widgets/billing_header_selector.dart'; // استدعاء الهيدر الجديد
import '../widgets/expandable_section_card.dart';
import '../widgets/extra_hours_log_content.dart';
import '../widgets/outstanding_balance_card.dart';
import '../widgets/subscription_details_content.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillingCubit(),
      child: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            // تم إزالة الـ AppBar بالكامل من هنا

            body: SafeArea( // إضافة SafeArea ضرورية جداً لحماية المحتوى من شريط البطارية
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الهيدر المخصص الجديد
                    const BillingHeaderSelector(),

                    SizedBox(height: 32.h), // مسافة أكبر شوية بين الهيدر والكارت المالي

                    // 2. الكارت المالي (Outstanding Balance)
                    const OutstandingBalanceCard(),
                    SizedBox(height: 24.h),

                    // 3. قسم الاشتراك
                    const ExpandableSectionCard(
                      title: 'Subscription Details',
                      icon: Icons.calendar_today_outlined,
                      content: SubscriptionDetailsContent(),
                    ),
                    SizedBox(height: 24.h),

                    // 4. قسم الغرامات
                    const ExpandableSectionCard(
                      title: 'Extra Hours Penalty Log',
                      icon: Icons.timer_outlined,
                      content: ExtraHoursLogContent(),
                    ),

                    SizedBox(height: 100.h), // لتفادي الـ Bottom Nav
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}