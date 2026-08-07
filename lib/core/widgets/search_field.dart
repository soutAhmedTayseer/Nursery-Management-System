import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../../core/theme/app_palette.dart';

/// Debounced pill search field shared by the sessions and subscriptions grids.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => widget.onChanged(value));
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: TextStyle(fontSize: 14.sp, color: palette.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.accentGreen, size: 22.w),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textTertiary, size: 18.w),
                  onPressed: _clear,
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}
