import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../sessions/presentation/cubit/sessions_cubit.dart';
// استيراد المكون الجديد
import '../widgets/child_subscription_card.dart';
import 'manage_subscription_screen.dart';

class SubscribedChildrenScreen extends StatelessWidget {
  const SubscribedChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد الأبعاد بناءً على وضعية التابلت لضمان عدم حدوث Overflow
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
                'Subscribed Children',
                style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)
            ),
            Text(
                'Manage financial plans, billing cycles, and subscription tiers.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)
            ),
            SizedBox(height: 32.h),

            // Children Grid
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  if (state is SessionsLoaded) {
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPortrait ? 3 : 4, // 3 في الرأسي و4 في الأفقي
                        mainAxisSpacing: 24.w,
                        crossAxisSpacing: 24.w,
                        childAspectRatio: isPortrait ? 0.75 : 0.88, // نسبة متغيرة لمنع الـ Overflow
                      ),
                      itemCount: state.displayedKids.length,
                      itemBuilder: (context, index) {
                        final child = state.displayedKids[index];
                        return ChildSubscriptionCard(
                          child: child,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManageSubscriptionScreen(childData: child),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}