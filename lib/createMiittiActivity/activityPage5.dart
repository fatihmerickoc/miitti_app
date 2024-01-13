// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';

class ActivityPage5 extends StatefulWidget {
  const ActivityPage5({
    Key? key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  }) : super(key: key);

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<ActivityPage5> createState() => _ActivityPage5State();
}

class _ActivityPage5State extends State<ActivityPage5> {
  int selectNumber = 0;
  bool decidedLater = false;
  Timestamp activityTime = Timestamp(0, 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.activity.activityTime = activityTime;
    widget.activity.timeDecidedLater = decidedLater;
    if (widget.activity.timeDecidedLater) {
      selectNumber = 2;
      widget.activity.activityTime = Timestamp.now();
    } else if (activityTime != Timestamp(0, 0)) {
      selectNumber = 1;
    }
  }

  // Widget for the toggle buttons to pick date
  Widget buildToggleButtons(String emoji, String title, int myInt) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (myInt == 1) {
            selectNumber = 1;
            activityTime = Timestamp(0, 0);

            pickDate(
              context: context,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  activityTime = Timestamp.fromDate(dateTime);
                  decidedLater = false;
                });
              },
            );
          } else {
            activityTime = Timestamp.now();
            decidedLater = true;
            selectNumber = 2;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0.w),
        width: 170.w,
        height: 200.w,
        decoration: BoxDecoration(
          gradient: selectNumber != myInt
              ? const LinearGradient(
                  colors: [
                    AppColors.lightRedColor,
                    AppColors.orangeColor,
                  ],
                )
              : null,
          color: selectNumber == myInt ? AppColors.purpleColor : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 70.sp,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.sp,
                color: Colors.white,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getSomeSpace(10),
            getMiittiActivityText('Mihin aikaan haluat aloittaa miitin?'),
            getSomeSpace(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildToggleButtons('⌛', 'Tarkka aika', 1),
                buildToggleButtons('🗓️', 'Sovitaan myöhemmin', 2),
              ],
            ),
            getSomeSpace(20),
            Text(
              decidedLater
                  ? "Sovitaan myöhemmin"
                  : timestampToString(activityTime),
              style: Styles.bodyTextStyle,
            ),
            const Expanded(child: SizedBox()),
            MyElevatedButton(
              onPressed: () {
                if (selectNumber != 0 && activityTime != Timestamp(0, 0)) {
                  widget.activity.activityTime = activityTime;
                  widget.activity.timeDecidedLater = decidedLater;

                  widget.onActivityDataChanged(widget.activity);
                  storeData();
                } else {
                  showSnackBar(
                      context,
                      'Aika ei voi olla tyhjä, yritä uudeelleen',
                      Colors.red.shade800);
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Seuravaa",
                      style: Styles.bodyTextStyle,
                    ),
            ),
            getSomeSpace(25),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Peruuta",
                style: Styles.bodyTextStyle,
              ),
            ),
            getSomeSpace(20),
          ],
        ),
      ),
    );
  }

  void storeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.saveMiittiActivityDataToFirebase(
      context: context,
      activityModel: widget.activity,
    );
  }
}
