import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConstantStyles {
  static const Color pink = Color(0xFFE05494);
  static const Color red = Color(0xFFF36269);
  static const Color orange = Color(0xFFF17517);
  static const Color purple = Color(0xFF5615CE);
  static const Color white = Color(0xFFFAFAFD);
  static const Color black = Color(0xFF090215);

  static TextStyle title = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32.sp,
    color: Colors.white,
  );

  static TextStyle body = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle textField = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );

  static TextStyle hintText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w300,
    color: Colors.white.withOpacity(0.6),
  );

  static TextStyle warning = TextStyle(
    fontSize: 12.sp,
    color: Colors.white.withOpacity(0.6),
  );

  final gapW5 = SizedBox(width: 5.w);
  final gapW10 = SizedBox(width: 10.w);
  final gapW15 = SizedBox(width: 15.w);
  final gapW20 = SizedBox(width: 20.w);

  final gapW50 = SizedBox(width: 50.w);

  final gapH5 = SizedBox(height: 5.h);
  final gapH10 = SizedBox(height: 10.h);
  final gapH15 = SizedBox(height: 15.h);
  final gapH20 = SizedBox(height: 20.w);

  final gapH50 = SizedBox(height: 50.h);
}
