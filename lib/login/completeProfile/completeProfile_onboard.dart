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
import 'package:miitti_app/utils/utils.dart';

class CompleteProfileOnboard extends StatefulWidget {
  const CompleteProfileOnboard({super.key});

  @override
  State<CompleteProfileOnboard> createState() => _CompleteProfileOnboard();
}

class _CompleteProfileOnboard extends State<CompleteProfileOnboard> {
  late PageController _pageController;

  File? myImage;

  late List<TextEditingController> _formControllers;

  final List<ConstantsOnboarding> onboardingScreens = [
    ConstantsOnboarding(
      title: 'Aloitetaan, mikä on etunimesi?',
      warningText:
          'Olet uniikki, muistathan siis käyttää vain omia henkilötietoja!',
      hintText: 'Syötä etunimesi',
      keyboardType: TextInputType.name,
    ),
    ConstantsOnboarding(
      title: 'Lisää aktiivinen sähköpostiosoite',
      warningText:
          'Emme käytä sähköpostiasi koskaan markkinointiin ilman lupaasi!',
      hintText: 'Syötä sähköpostiosoitteesi',
      keyboardType: TextInputType.emailAddress,
    ),
    ConstantsOnboarding(
      title: 'Mikä on puhelinnumerosi?',
      warningText:
          'Lähetämme hetken kuluttua vahvistuskoodin sisältävän tekstiviestin.',
      hintText: '+358453301000',
      keyboardType: TextInputType.phone,
    ),
    ConstantsOnboarding(
      title: 'Kerro meille syntymäpäiväsi',
      warningText: 'Laskemme tämän perusteella ikäsi',
      hintText: 'Syötä syntymäpäiväsi',
      keyboardType: TextInputType.datetime,
      isBirthday: true,
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

  @override
  void initState() {
    super.initState();
    _formControllers =
        List.generate(onboardingScreens.length, (_) => TextEditingController());
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _formControllers) {
      controller.dispose();
    }
    super.dispose();
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
                        screen.mainWidget ??
                            ConstantsCustomTextField(
                              readOnly:
                                  screen.isBirthday != null ? true : false,
                              onTap: () {
                                //if user is on the birthday screen
                                if (screen.isBirthday != null) {
                                  pickBirthdayDate(
                                    context: context,
                                    onDateTimeChanged: (dateTime) {
                                      setState(() {
                                        _formControllers[index].text =
                                            '${dateTime.month}/${dateTime.day}/${dateTime.year}';
                                      });
                                    },
                                  );
                                }
                              },
                              hintText: screen.hintText,
                              controller: _formControllers[index],
                              keyboardType: screen.keyboardType,
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
                            if (_pageController.page != 3) {
                              if (_formControllers[index]
                                  .text
                                  .trim()
                                  .isNotEmpty) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.linear,
                                );
                              } else {
                                showSnackBar(
                                  context,
                                  'Kysymys "${screen.title}" ei voi olla tyhjä!',
                                  ConstantStyles.red,
                                );
                              }
                            } else {
                              //save all the values to firebase
                            }
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
