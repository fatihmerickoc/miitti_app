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
      margin: EdgeInsets.symmetric(
          vertical: 10.h, horizontal: highlight ? 16.w : 20.w),
      child: Container(
        height: highlight ? 90.h : 80.h,
        decoration: BoxDecoration(
          color: AppColors.wineColor,
          border: Border.all(
              color: AppColors.purpleColor, width: highlight ? 2.0 : 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: SizedBox(
                width: double.maxFinite,
                child: Image.network(
                  image,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                color: const Color.fromARGB(120, 0, 0, 0),
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Rubik",
                        color: Colors.white),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Rubik",
                      color: Colors.grey.shade200,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 24.w,
                width: 100.h,
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
