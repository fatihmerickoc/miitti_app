import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String mainText;
  final String leftButtonText;
  final String rightButtonText;
  final Widget mainContent;

  const ConfirmDialog({
    required this.title,
    required this.mainText,
    this.leftButtonText = 'Poista',
    this.rightButtonText = 'Ei',
    this.mainContent = const SizedBox(),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkPurpleColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 20.0.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            mainText,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16.0.sp,
              color: Colors.white70,
            ),
          ),
          mainContent,
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // User pressed the cancel button
            Navigator.of(context).pop(false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey, // Set the button color
            foregroundColor: Colors.white, // Set the text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            rightButtonText!,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // User pressed the delete button
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600, // Set the button color
            foregroundColor: Colors.white, // Set the text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            leftButtonText!,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
