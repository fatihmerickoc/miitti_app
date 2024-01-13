// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unused_field, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:io';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';

import '../constants/miittiUser.dart';

class OnBoardingScreenPhoto extends StatefulWidget {
  OnBoardingScreenPhoto(
      {required this.controller,
      required this.onUserDataChanged,
      required this.user,
      required this.onImageChanged,
      super.key});

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  final Function onImageChanged;
  PageController controller;

  @override
  State<OnBoardingScreenPhoto> createState() => _OnBoardingScreenPhotoState();
}

class _OnBoardingScreenPhotoState extends State<OnBoardingScreenPhoto> {
  File? image;

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  Widget createThatSection() {
    return Container(
      padding: EdgeInsets.only(left: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Valitse profiilikuvasi', style: Styles.sectionTitleStyle),
          Text(
            'Lataa kuva, jotka kertoo persoonastasi enemmän kuin tuhat sanaa',
            style: Styles.sectionSubtitleStyle,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              getMiittiLogo(),
              SizedBox(
                height: 50.h,
              ),
              createThatSection(),
              Container(
                height: 400.h,
                padding: EdgeInsets.all(18.w),
                child: GestureDetector(
                  onTap: () {
                    selectImage();
                  },
                  child: image != null
                      ? SizedBox(
                          height: double.maxFinite,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.lightRedColor,
                                AppColors.orangeColor,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.photo_library,
                              size: 60.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              MyElevatedButton(
                onPressed: () {
                  if (image != null) {
                    widget.onImageChanged(image);
                    widget.controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                  } else {
                    showSnackBar(
                        context,
                        'Kuva ei voi olla tyhjä, yritä uudelleen!',
                        Colors.red.shade800);
                  }
                },
                child: Text("Seuraava", style: Styles.bodyTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
