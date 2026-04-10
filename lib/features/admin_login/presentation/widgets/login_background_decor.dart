import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginBackgroundDecor extends StatelessWidget {
  const LoginBackgroundDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Leaf image on the bottom left
        Positioned(
          bottom: 0,
          left: 0,
          child: Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/images/leaf_left.png',
              width: 250.w,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => SizedBox(
                width: 250.w,
                height: 250.h,
                child: Placeholder(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),

        // 2. Leaf image on the bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/images/leaf_right.png',
              width: 200.w,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => SizedBox(
                width: 200.w,
                height: 200.h,
                child: Placeholder(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
