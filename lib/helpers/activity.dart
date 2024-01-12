import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miitti_activity.dart';

class Activity {
  final String name;
  final String emojiData;

  Activity({required this.name, required this.emojiData});

  static Widget getSymbol(MiittiActivity activity) {
    return activity is CommercialActivity
        ? Stack(
            children: [
              Image.network(
                activity.activityPhoto,
                height: 100.h,
                width: 100.w,
                errorBuilder: (cpntext, error, stacktrace) =>
                    Image.asset('images/circlebackground.png'),
              ),
              const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.verified,
                  color: AppColors.purpleColor,
                ),
              )
            ],
          )
        : Image.asset(
            'images/${activity.activityCategory.toLowerCase()}.png',
            height: 100.h,
            errorBuilder: (cpntext, error, stacktrace) =>
                Image.asset('images/circlebackground.png'),
          );
  }
}
