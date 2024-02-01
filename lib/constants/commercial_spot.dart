import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';

class CommercialSpot {
  double long;
  double lati;
  String name;
  String address;
  String image;
  String admin;

  CommercialSpot({
    required this.lati,
    required this.long,
    required this.name,
    required this.address,
    required this.image,
    required this.admin,
  });

  factory CommercialSpot.fromMap(Map<String, dynamic> map) {
    return CommercialSpot(
      lati: map['lati'] ?? 0,
      long: map['long'] ?? 0,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      image: map['image'] ?? '',
      admin: map['admin'] ?? '',
    );
  }

  Card getWidget(bool highlight) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.all(10.0.w),
      child: Container(
        width: highlight ? 400.w : 380.w,
        height: highlight ? 160.w : 120.w,
        decoration: BoxDecoration(
          color: AppColors.wineColor,
          border: Border.all(
              color: AppColors.purpleColor, width: highlight ? 4.0 : 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [Text(name), Text(address)],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 28,
                width: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.transparentPurple,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  "Sponsoroitu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: 'Rubik',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
