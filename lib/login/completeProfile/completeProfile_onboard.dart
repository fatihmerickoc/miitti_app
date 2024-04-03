import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_customTextField.dart';
import 'package:miitti_app/constants/constants_onboarding.dart';
import 'package:miitti_app/constants/constants_styles.dart';

import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/onboardingScreens/obs1_name.dart';
import 'package:miitti_app/onboardingScreens/obs4_email.dart';
import 'package:miitti_app/onboardingScreens/obs5_info.dart';
import 'package:miitti_app/onboardingScreens/obs6_photo.dart';
import 'package:miitti_app/onboardingScreens/obs7_qa.dart';
import 'package:miitti_app/onboardingScreens/onboarding.dart';

class CompleteProfileOnboard extends StatefulWidget {
  const CompleteProfileOnboard({super.key});

  @override
  State<CompleteProfileOnboard> createState() => _CompleteProfileOnboard();
}

class _CompleteProfileOnboard extends State<CompleteProfileOnboard> {
  late PageController _pageController;
  late TextEditingController _textEditingController;

  File? myImage;

  final List<ConstantsOnboarding> onboardingScreens = [
    ConstantsOnboarding(
      title: 'Aloitetaan, mikä on etunimesi?',
      warningText:
          'Olet uniikki, muistathan siis käyttää vain omia henkilötietoja!',
      hintText: 'Syötä etunimesi',
    ),
    ConstantsOnboarding(
      title: 'Lisää aktiivinen sähköpostiosoite',
      warningText:
          'Emme käytä sähköpostiasi koskaan markkinointiin ilman lupaasi!',
      hintText: 'Syötä sähköpostiosoitteesi',
    ),
    ConstantsOnboarding(
      title: 'Mikä on puhelinnumerosi?',
      warningText:
          'Lähetämme hetken kuluttua vahvistuskoodin sisältävän tekstiviestin.',
      hintText: '+358453301000',
    ),
    ConstantsOnboarding(
      title: 'Kerro meille syntymäpäiväsi',
      warningText: 'Laskemme tämän perusteella ikäsi',
      hintText: 'Syötä syntymäpäiväsi',
    ),
  ];

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
    fcmToken: '',
    userRegistrationDate: '',
  );

  void _updateUserData(MiittiUser updatedUser) {
    setState(() {
      _miittiUser = updatedUser;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textEditingController.dispose();
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
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingScreens.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  ConstantsOnboarding screen = onboardingScreens[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        const Spacer(),
                        Text(
                          screen.title,
                          style: ConstantStyles.title,
                        ),
                        ConstantStyles().gapH20,
                        ConstantsCustomTextField(
                          hintText: screen.hintText,
                          controller: _textEditingController,
                        ),
                        ConstantStyles().gapH5,
                        Text(
                          screen.warningText,
                          style: ConstantStyles.warning,
                        ),
                        const Spacer(),
                        ConstantsCustomButton(
                          buttonText: 'Seuraava',
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear,
                            );
                          },
                        ), //Removed extra padding in ConstantsCustomButton
                        ConstantStyles().gapH10,
                        ConstantsCustomButton(
                          buttonText: 'Takaisin',
                          isWhiteButton: true,
                          onPressed: () {
                            if (_pageController.page != 0) {
                              print("PAGE NUMBER: ${_pageController.page}");
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.linear,
                              );
                            }
                          },
                        ), //Removed extra padding in ConstantsCustomButton
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
