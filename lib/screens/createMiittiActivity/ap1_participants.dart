// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:miitti_app/data/person_activity.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/my_elevated_button.dart';

import '../../constants/constants.dart';

class AP1Participants extends StatefulWidget {
  const AP1Participants({
    super.key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  });

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<AP1Participants> createState() => _AP1ParticipantsState();
}

class _AP1ParticipantsState extends State<AP1Participants> {
  int selectedValue = 0;
  double friendsCount = 2;
  bool isMultiplePerson = true;

  @override
  void initState() {
    super.initState();
    friendsCount = widget.activity.personLimit.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getSomeSpace(20),
            getMiittiActivityText(
                'Osallistujien määrä, jotka osallistuvat tapahtumaan?'),
            getSomeSpace(20),
            Slider(
              activeColor: AppColors.purpleColor,
              inactiveColor: AppColors.lightPurpleColor,
              value: friendsCount,
              min: 2,
              max: 10,
              onChanged: (newValue) {
                setState(() {
                  friendsCount = newValue;
                });
              },
              label: friendsCount.round().toString(),
            ),
            Text(
              friendsCount.round().toString() +
                  (friendsCount.round() > 1 ? " osallistujaa" : " osallistuja"),
              style: Styles.titleTextStyle,
            ),
            Expanded(
              child: Container(),
            ),
            MyElevatedButton(
              onPressed: () {
                // Update the person limit in the activity object
                widget.activity.personLimit = friendsCount.round();
                widget.onActivityDataChanged(widget.activity);
                // Move to the next page using the controller
                widget.controller.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
              },
              child: Text(
                "Seuraava",
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
}
