import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/onboardingScreens/obs1_name.dart';
import 'package:miitti_app/onboardingScreens/obs4_email.dart';
import 'package:miitti_app/onboardingScreens/obs5_info.dart';
import 'package:miitti_app/onboardingScreens/obs6_photo.dart';
import 'package:miitti_app/onboardingScreens/obs7_qa.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'obs8_activities.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller = PageController();

  File? myImage;

  MiittiUser _miittiUser = MiittiUser(
      userName: '',
      userEmail: '',
      uid: '',
      userPhoneNumber: '',
      userBirthday: '',
      userArea: '',
      userFavoriteActivities: {},
      userChoices: {},
      userGender: '',
      userLanguages: {},
      profilePicture: '',
      invitedActivities: {},
      userStatus: '',
      userSchool: '',
      fcmToken: '');

  void _updateUserData(MiittiUser updatedUser) {
    setState(() {
      _miittiUser = updatedUser;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTheImage(File sendedImage) {
    setState(() {
      myImage = sendedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  OnBoardingScreenName(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                  ),
                  OnBoardingScreenEmail(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                  ),
                  OnBoardingScreenInfo(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                  ),
                  OnBoardingScreenPhoto(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                    onImageChanged: _updateTheImage,
                  ),
                  OnBoardingScreenQA(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                  ),
                  OnBoardingScreenActivities(
                    controller: _controller,
                    onUserDataChanged: _updateUserData,
                    user: _miittiUser,
                    userPickedImage: myImage,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                        curve: Curves.linear,
                      );
                    },
                    child: Container(
                      height: 56.w,
                      width: 56.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.lightRedColor,
                            AppColors.orangeColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 6,
                    onDotClicked: (index) {},
                    effect: SwapEffect(
                      activeDotColor: AppColors.purpleColor,
                      dotColor: AppColors.lightPurpleColor,
                      dotHeight: 30.w,
                      dotWidth: 30.w,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
