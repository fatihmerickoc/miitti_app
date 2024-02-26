import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';

import '../constants/constants.dart';

class ActivityPage4 extends StatefulWidget {
  const ActivityPage4({
    super.key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  });

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<ActivityPage4> createState() => _ActivityPage4State();
}

class _ActivityPage4State extends State<ActivityPage4> {
  String selectedActivity = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedActivity = widget.activity.activityCategory;
  }

  void _toggleSelectedActivity(String activity) {
    setState(() {
      selectedActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getSomeSpace(20),
            getMiittiActivityText('Valitse alta sopiva kategoria miitille'),
            getSomeSpace(20),
            Expanded(
              child: GridView.builder(
                itemCount: activities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemBuilder: (context, index) {
                  final activity = activities.keys.toList()[index];
                  final isSelected = activity == selectedActivity;
                  return GestureDetector(
                    onTap: () => _toggleSelectedActivity(activity),
                    child: Container(
                      height: 100.w,
                      width: 50.w,
                      padding: EdgeInsets.all(10.0.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.purpleColor
                            : Colors.transparent,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            Activity.getActivity(activity).emojiData,
                            style: TextStyle(fontSize: 50.0.sp),
                          ),
                          Text(
                            Activity.getActivity(activity).name,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.activityNameTextStyle,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            MyElevatedButton(
              onPressed: () {
                if (selectedActivity.isNotEmpty) {
                  widget.activity.activityCategory = selectedActivity;
                  widget.onActivityDataChanged(widget.activity);
                  widget.controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                } else {
                  showSnackBar(
                      context,
                      'Kategoria ei voi olla tyhjä, yritä uudeelleen',
                      Colors.red.shade800);
                }
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
