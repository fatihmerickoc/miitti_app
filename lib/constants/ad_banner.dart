import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AdBanner {
  String image;
  String link;
  Set<String> targetActivities;
  int targetMinAge;
  int targetMaxAge;
  bool targetMen;
  bool targetWomen;
  bool targetNonBinary;

  AdBanner({
    required this.image,
    required this.link,
    required this.targetActivities,
    required this.targetMinAge,
    required this.targetMaxAge,
    required this.targetMen,
    required this.targetWomen,
    required this.targetNonBinary,
  });

  factory AdBanner.fromMap(Map<String, dynamic> map) {
    return AdBanner(
      image: map['image'] ?? '',
      link: map['link'] ?? '',
      targetActivities: (map['targetActivities'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      targetMinAge: map['targetMinAge'] ?? 18,
      targetMaxAge: map['targetMaxAge'] ?? 80,
      targetMen: map['targetMen'] ?? true,
      targetWomen: map['targetWomen'] ?? true,
      targetNonBinary: map['targetNonBinary'] ?? true,
    );
  }

  bool targetUser(MiittiUser user) {
    int age = calculateAge(user.userBirthday);
    if (age < targetMinAge || age > targetMaxAge) return false;

    if (user.userGender == "Mies" && !targetMen) return false;
    if (user.userGender == "Nainen" && !targetMen) return false;
    if (user.userGender == "Ei-binäärinen" && !targetMen) return false;

    bool suitable = false;
    for (var activity in targetActivities) {
      if (user.userFavoriteActivities.contains(activity)) suitable = true;
    }

    return suitable;
  }

  bool targetCommon(MiittiUser user, MiittiUser another) {
    return targetUser(user) && targetUser(another);
  }

  static Future<GestureDetector> getBanner(AuthProvider ap) async {
    AdBanner? value;

    List<AdBanner> banners = await ap.fetchAds();

    if (banners.isEmpty) {
      return GestureDetector(
        onTap: () {},
        child: Container(),
      );
    }

    for (AdBanner b in banners) {
      if (b.targetUser(ap.miittiUser)) {
        value = b;
        break;
      }
    }

    value ??= banners[Random().nextInt(banners.length)];

    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(value!.link));
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.wineColor,
            border: Border.all(color: AppColors.purpleColor, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Stack(
            children: [
              Image.network(
                value.image,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 20,
                  width: 80,
                  alignment: Alignment.bottomRight,
                  decoration: const BoxDecoration(
                    color: AppColors.purpleColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Text(
                    "Sponsored",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
