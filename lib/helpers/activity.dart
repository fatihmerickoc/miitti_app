import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miitti_activity.dart';

class Activity {
  final String name;
  final String emojiData;
  const Activity({required this.name, required this.emojiData});

  static Activity getActivity(String category) {
    if (activities.containsKey(category)) {
      return activities[category]!;
    } else {
      return activities.values.firstWhere((element) => element.name == category,
          orElse: () => activities['adventure']!);
    }
  }

  static String solveActivityId(String category) {
    print("Solving category: $category");
    if (!activities.containsKey(category)) {
      bool categoryFound = false;
      for (String key in activities.keys) {
        if (activities[key]!.name == category) {
          category = key;
          categoryFound = true;
          print("found $category");
          break;
        }
      }

      if (!categoryFound) {
        print("$category not found in activities. Defaulting to adventure.");
        category = 'adventure';
      }
    } else {
      print(category);
    }
    return category;
  }

  static Widget getSymbol(MiittiActivity activity, [double size = 34]) {
    return activity is CommercialActivity
        ? Padding(
            padding: EdgeInsets.all((size / 2.8).h),
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purpleColor,
                  radius: (size + 3).r,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(activity.activityPhoto),
                    radius: size.r,
                    onBackgroundImageError: (exception, stackTrace) => AssetImage(
                        'images/${solveActivityId(activity.activityCategory)}.png'),
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
            'images/${solveActivityId(activity.activityCategory)}.png',
            height: 100.h,
            errorBuilder: (cpntext, error, stacktrace) =>
                Image.asset('images/adventure.png'),
          );
  }
}
