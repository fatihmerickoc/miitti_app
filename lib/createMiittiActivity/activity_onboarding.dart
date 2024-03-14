import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/createMiittiActivity/ap1_participants.dart';
import 'package:miitti_app/createMiittiActivity/ap2_text.dart';
import 'package:miitti_app/createMiittiActivity/ap3_location.dart';
import 'package:miitti_app/createMiittiActivity/ap4_category.dart';
import 'package:miitti_app/createMiittiActivity/ap5_time.dart';

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
        body: SafeArea(
          //child: Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: [
              // Display each activity page
              AP4Category(
                activity: _miittiActivity,
                onActivityDataChanged: _updateActivityData,
                controller: _controller,
              ),
              AP3Location(
                activity: _miittiActivity,
                onActivityDataChanged: _updateActivityData,
                controller: _controller,
              ),
              AP5Time(
                activity: _miittiActivity,
                onActivityDataChanged: _updateActivityData,
                controller: _controller,
              ),
              AP1Participants(
                activity: _miittiActivity,
                onActivityDataChanged: _updateActivityData,
                controller: _controller,
              ),
              AP2Text(
                activity: _miittiActivity,
                onActivityDataChanged: _updateActivityData,
                controller: _controller,
              ),
            ],
          ),
        ),
        //),
      ),
    );
  }
}
