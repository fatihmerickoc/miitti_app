import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';

class MyElevatedButton extends StatelessWidget {
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.width = 380,
    this.height = 65,
    this.gradient = const LinearGradient(colors: [
      AppColors.lightRedColor,
      AppColors.orangeColor,
    ]),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width!.w, // Use .w to make width responsive
      height: height.h, // Use .h to make height responsive
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: Styles.buttonStyle,
        child: child,
      ),
    );
  }
}
