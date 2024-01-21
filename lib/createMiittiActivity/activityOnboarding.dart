// ignore_for_file: prefer_const_constructors, unused_field, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/createMiittiActivity/activityPage1.dart';
import 'package:miitti_app/createMiittiActivity/activityPage2.dart';
import 'package:miitti_app/createMiittiActivity/activityPage3.dart';
import 'package:miitti_app/createMiittiActivity/activityPage4.dart';
import 'package:miitti_app/createMiittiActivity/activityPage5.dart';

import '../constants/constants.dart';

class ActivityOnboarding extends StatefulWidget {
  const ActivityOnboarding({super.key});

  @override
  State<ActivityOnboarding> createState() => _ActivityOnboardingState();
}

class _ActivityOnboardingState extends State<ActivityOnboarding> {
  late PageController _controller;

  PersonActivity _miittiActivity = PersonActivity(
    activityTitle: '',
    activityDescription: '',
    activityCategory: '',
    admin: '',
    activityUid: '',
    activityLong: 0,
    activityLati: 0,
    activityAdress: '',
    activityTime: Timestamp.now(),
    timeDecidedLater: false,
    isMoneyRequired: false,
    personLimit: 2,
    participants: {},
    requests: {},
    adminAge: 0,
    adminGender: '',
  );

  void _updateActivityData(PersonActivity updatedActivity) {
    setState(() {
      _miittiActivity = updatedActivity;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !Navigator.of(context).userGestureInProgress,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70.h,
                ),
                SizedBox(
                  height: 700.h,
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: [
                      // Display each activity page
                      ActivityPage1(
                        activity: _miittiActivity,
                        onActivityDataChanged: _updateActivityData,
                        controller: _controller,
                      ),
                      ActivityPage2(
                        activity: _miittiActivity,
                        onActivityDataChanged: _updateActivityData,
                        controller: _controller,
                      ),
                      ActivityPage3(
                        activity: _miittiActivity,
                        onActivityDataChanged: _updateActivityData,
                        controller: _controller,
                      ),
                      ActivityPage4(
                        activity: _miittiActivity,
                        onActivityDataChanged: _updateActivityData,
                        controller: _controller,
                      ),
                      ActivityPage5(
                        activity: _miittiActivity,
                        onActivityDataChanged: _updateActivityData,
                        controller: _controller,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
