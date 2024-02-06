// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/privacyAgreement.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';
import 'dart:io';
import '../constants/miittiUser.dart';

class OnBoardingScreenActivities extends StatefulWidget {
  OnBoardingScreenActivities(
      {required this.controller,
      required this.onUserDataChanged,
      required this.user,
      required this.userPickedImage,
      super.key});

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  File? userPickedImage;
  PageController controller;

  @override
  State<OnBoardingScreenActivities> createState() =>
      _OnBoardingScreenActivitiesState();
}

class _OnBoardingScreenActivitiesState
    extends State<OnBoardingScreenActivities> {
  String search = '';

  List<String> filteredActivities = [];
  Set<String> favoriteActivities = <String>{};

  void _search(String input) {
    setState(() {
      search = input;
      filteredActivities = activities.entries
          .where((activity) =>
              activity.value.name.toLowerCase().contains(search.toLowerCase()))
          .map((e) => e.key)
          .toList();
    });
  }

  void _toggleFavoriteActivity(String activity) {
    setState(() {
      if (favoriteActivities.contains(activity)) {
        favoriteActivities.remove(activity);
      } else {
        if (favoriteActivities.length < 9) {
          favoriteActivities.add(activity);
        }
      }
    });
  }

  Widget createSection({
    required String textTitle,
    required String textSubtitle,
    required Widget inputWidget,
    required Widget secondWidget,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: 15.w,
        right: 15.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textTitle,
            style: Styles.sectionTitleStyle,
          ),
          Text(
            textSubtitle,
            style: Styles.sectionSubtitleStyle,
          ),
          SizedBox(
            height: 10.h,
          ),
          inputWidget,
          SizedBox(
            height: 10.h,
          ),
          secondWidget,
          SizedBox(
            height: 30.h,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    filteredActivities = activities.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              getMiittiLogo(),
              SizedBox(
                height: 40.0.h,
              ),
              createSection(
                textTitle: 'Lisää lempiaktiviteettisi',
                textSubtitle:
                    'Valitse vähintään 3 lempiaktiviteettisi, mitä haluaisit tehdä muiden kanssa',
                inputWidget: getOurTextField(
                  myPadding: EdgeInsets.only(right: 10.w),
                  myOnChanged: _search,
                  hintText: 'Hae aktiviteettia',
                  myKeyboardType: TextInputType.text,
                ),
                secondWidget: SizedBox(
                  height: 350.h,
                  child: GridView.builder(
                    itemCount: filteredActivities.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      final isSelected = favoriteActivities.contains(activity);
                      return GestureDetector(
                        onTap: () => _toggleFavoriteActivity(activity),
                        child: Container(
                          height: 100.h,
                          width: 50.w,
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.purpleColor
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: Column(
                            children: [
                              Text(
                                Activity.getActivity(activity).emojiData,
                                style: TextStyle(fontSize: 50.sp),
                              ),
                              Text(
                                Activity.getActivity(activity).name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 19.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              MyElevatedButton(
                onPressed: () {
                  if (favoriteActivities.length > 2) {
                    widget.user.userFavoriteActivities = favoriteActivities;
                    widget.onUserDataChanged(widget.user);

                    pushNRemoveUntil(
                      context,
                      PrivacyAgreement(
                        user: widget.user,
                        image: widget.userPickedImage,
                      ),
                    );
                  } else {
                    showSnackBar(
                        context,
                        'Valitse vähintään 3 lempiaktiviteettia, yritä uudelleen!',
                        Colors.red.shade800);
                  }
                },
                child: Text("Seuravaa", style: Styles.bodyTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
