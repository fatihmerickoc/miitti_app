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
        ? Padding(
            padding: EdgeInsets.all(13.0.h),
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purpleColor,
                  radius: 37.r,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(activity.activityPhoto),
                    radius: 34.r,
                    onBackgroundImageError: (exception, stackTrace) => AssetImage(
                        'images/${activity.activityCategory.toLowerCase()}.png'),
                  ),
                ),
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: AppColors.purpleColor,
                        size: 25,
                      ),
                      Icon(
                        Icons.verified,
                        color: AppColors.lightPurpleColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Image.asset(
            'images/${activity.activityCategory.toLowerCase()}.png',
            height: 100.h,
            errorBuilder: (cpntext, error, stacktrace) =>
                Image.asset('images/circlebackground.png'),
          );
  }
}
