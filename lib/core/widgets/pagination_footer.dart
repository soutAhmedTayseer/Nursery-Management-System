import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Page-number footer shared by grids paginated through a fixed [pageSize].
class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.itemCount,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final int itemCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    int startItem = (currentPage - 1) * pageSize + 1;
    int endItem = startItem + itemCount - 1;
    if (totalCount == 0) {
      startItem = 0;
      endItem = 0;
    }

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'sessions_pagination_showing'.tr(namedArgs: {
              'start': '$startItem',
              'end': '$endItem',
              'total': '$totalCount',
            }),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              _arrowBtn(Icons.chevron_left, isActive: currentPage > 1, onTap: () {
                if (currentPage > 1) onPageChanged(currentPage - 1);
              }),
              SizedBox(width: 8.w),
              ...List.generate(totalPages, (index) {
                final pageNum = index + 1;
                return _pageNumber(pageNum.toString(), isActive: pageNum == currentPage, onTap: () => onPageChanged(pageNum));
              }),
              SizedBox(width: 8.w),
              _arrowBtn(Icons.chevron_right, isActive: currentPage < totalPages, onTap: () {
                if (currentPage < totalPages) onPageChanged(currentPage + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageNumber(String n, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(color: isActive ? AppColors.accentGreen : Colors.grey.shade200, shape: BoxShape.circle),
        child: Center(child: Text(n, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _arrowBtn(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
        child: Icon(icon, size: 20.w, color: isActive ? Colors.black87 : Colors.grey.shade400),
      ),
    );
  }
}
