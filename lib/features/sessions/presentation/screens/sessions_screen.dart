import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/sessions_cubit.dart';
import '../widgets/child_session_card.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Identify orientation for dynamic grid adjustments
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Header
            _buildHeader(),
            SizedBox(height: 32.h),

            // 3. Dynamic Grid
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  if (state is SessionsLoading) return const Center(child: CircularProgressIndicator());
                  
                  if (state is SessionsLoaded) {
                    if (state.displayedKids.isEmpty) {
                       return Center(child: Text('No sessions found.', style: TextStyle(fontSize: 18.sp, color: Colors.grey)));
                    }
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPortrait ? 3 : 4,
                        mainAxisSpacing: 24.w,
                        crossAxisSpacing: 24.w,
                        childAspectRatio: isPortrait ? 0.72 : 0.85, 
                      ),
                      itemCount: state.displayedKids.length,
                      itemBuilder: (context, index) => ChildSessionCard(child: state.displayedKids[index]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // 4. Dynamic Pagination Footer
            BlocBuilder<SessionsCubit, SessionsState>(
              builder: (context, state) {
                if (state is SessionsLoaded) {
                  return _buildDynamicPaginationFooter(context, state);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Sessions', style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text('Monitoring current child presence and scheduled plans.', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Row(
          children: [
            _buildSummarySmallCard('CURRENT COUNT', '24 Children', Icons.face_rounded),
            SizedBox(width: 16.w),
            _buildSummarySmallCard('SESSION BLOCK', '08:00 - 13:00', Icons.schedule),
          ],
        )
      ],
    );
  }

  Widget _buildSummarySmallCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        children: [
          CircleAvatar(radius: 18.r, backgroundColor: const Color(0xFFF0F4EF), child: Icon(icon, color: const Color(0xFF4A7A3A), size: 18.w)),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDynamicPaginationFooter(BuildContext context, SessionsLoaded state) {
    final cubit = context.read<SessionsCubit>();
    
    int startItem = (state.currentPage - 1) * cubit.itemsPerPage + 1;
    int endItem = startItem + state.displayedKids.length - 1;
    if (state.totalCount == 0) {
      startItem = 0; endItem = 0;
    }

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startItem to $endItem of ${state.totalCount} active registrations', 
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600)
          ),
          Row(
            children: [
              _buildPageArrowBtn(
                Icons.chevron_left, 
                isActive: state.currentPage > 1,
                onTap: () {
                  if (state.currentPage > 1) cubit.changePage(state.currentPage - 1);
                }
              ),
              SizedBox(width: 8.w),
              
              ...List.generate(state.totalPages, (index) {
                int pageNum = index + 1;
                return _buildPageNumber(
                  pageNum.toString(), 
                  isActive: pageNum == state.currentPage,
                  onTap: () => cubit.changePage(pageNum),
                );
              }),
              
              SizedBox(width: 8.w),
              _buildPageArrowBtn(
                Icons.chevron_right, 
                isActive: state.currentPage < state.totalPages,
                onTap: () {
                  if (state.currentPage < state.totalPages) cubit.changePage(state.currentPage + 1);
                }
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPageNumber(String n, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w, height: 36.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(color: isActive ? const Color(0xFF4A7A3A) : Colors.grey.shade200, shape: BoxShape.circle),
        child: Center(child: Text(n, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildPageArrowBtn(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w, height: 36.w,
        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
        child: Icon(icon, size: 20.w, color: isActive ? Colors.black87 : Colors.grey.shade400),
      ),
    );
  }
}
