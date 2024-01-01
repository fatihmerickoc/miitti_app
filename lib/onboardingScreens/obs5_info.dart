// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';

import '../constants/miittiUser.dart';

class OnBoardingScreenInfo extends StatefulWidget {
  OnBoardingScreenInfo({
    required this.controller,
    required this.onUserDataChanged,
    required this.user,
    super.key,
  });

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  PageController controller;

  @override
  State<OnBoardingScreenInfo> createState() => _OnBoardingScreenInfoState();
}

class _OnBoardingScreenInfoState extends State<OnBoardingScreenInfo> {
  final birthDayController = TextEditingController();
  final myAlueController = TextEditingController();
  final mySchoolController = TextEditingController();

  final customLanguageController = TextEditingController();

  final _schoolFocusNode = FocusNode();
  final _alueFocusNode = FocusNode();

  final List<String> languages = [
    '🇫🇮',
    '🇸🇪',
    '🇬🇧',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myAlueController.text = widget.user.userArea;
    mySchoolController.text = widget.user.userSchool;
    birthDayController.text = widget.user.userBirthday;
    selectedLanguages = widget.user.userLanguages;
  }

  @override
  void dispose() {
    birthDayController.dispose();
    myAlueController.dispose();
    mySchoolController.dispose();
    customLanguageController.dispose();
    _alueFocusNode.dispose();
    _schoolFocusNode.dispose();
    super.dispose();
  }

  Gender selectedGender = Gender.male;

  Set<String> selectedLanguages = {};

  Widget _buildLanguageButton(
    String language,
  ) {
    final bool isSelected = selectedLanguages.contains(language);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedLanguages.remove(language);
          } else {
            selectedLanguages.add(language);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 20.w),
        width: 65.w,
        height: 65.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPurpleColor
              : AppColors.lightPurpleColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            language,
            style: TextStyle(
              fontSize: 40.0.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmojiButton(String emoji, Gender value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 20.0.w),
        width: 65.w,
        height: 65.h,
        decoration: BoxDecoration(
          color: selectedGender == value
              ? AppColors.lightPurpleColor
              : AppColors.lightPurpleColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 40.sp,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40.h,
                ),
                getChatBubble(
                    'Hei ${widget.user.userName}, hauska tutustua 👋'),
                getChatBubble(
                    'Profiilisi on melkein valmis, kerro meille vielä itsestäsi ja persoonastasi 😃'),
                getSections(
                  title: 'Mitä sukupuolta edustat',
                  subtitle:
                      'Sukupuoli ei määrittele sinua, mutta sen avulla löydät sopivia miitteja',
                  mainWidget: Row(
                    children: [
                      buildEmojiButton('👨', Gender.male),
                      buildEmojiButton('👩', Gender.female),
                      buildEmojiButton('🏳️‍⚧️', Gender.nonBinary),
                    ],
                  ),
                ),
                getSections(
                  title: 'Missä asustelet',
                  subtitle:
                      'Emme tunge kylään, mutta näin osaamme ehdottaa sopivia miittejä alueellasi',
                  mainWidget: getOurTextField(
                    myPadding: EdgeInsets.only(right: 10.w),
                    myController: myAlueController,
                    myFocusNode: _alueFocusNode,
                    hintText: 'Helsinki',
                    myOnTap: () {
                      if (_alueFocusNode.hasFocus) {
                        _alueFocusNode.unfocus();
                      }
                    },
                    myKeyboardType: TextInputType.streetAddress,
                  ),
                ),
                getSections(
                  title: 'Missä opiskelet',
                  subtitle: 'Yliopisto vai kahvilan nurkka?',
                  mainWidget: getOurTextField(
                    myPadding: EdgeInsets.only(right: 10.w),
                    myController: mySchoolController,
                    myFocusNode: _schoolFocusNode,
                    hintText: 'Helsingin Yliopisto',
                    myOnTap: () {
                      if (_schoolFocusNode.hasFocus) {
                        _alueFocusNode.unfocus();
                      }
                    },
                    myKeyboardType: TextInputType.text,
                  ),
                ),
                getSections(
                  title: 'Mitä kieliä puhut',
                  subtitle: 'Valitse ne kielet, joita puhut',
                  mainWidget: Row(
                    children: [
                      _buildLanguageButton(
                        languages[0],
                      ),
                      _buildLanguageButton(
                        languages[1],
                      ),
                      _buildLanguageButton(
                        languages[2],
                      ),
                    ],
                  ),
                ),
                getSections(
                  title: 'Lisää syntymäpäiväsi',
                  subtitle:
                      'Näin voimme vahvistaa ikäsi ja onnitella sinua syntymäpäivänäsi',
                  mainWidget: getOurTextField(
                    myPadding: EdgeInsets.only(right: 10.w),
                    myFocusNode: null,
                    myReadOnly: true,
                    myController: birthDayController,
                    myKeyboardType: TextInputType.datetime,
                    hintText: '16/10/2000',
                    myOnTap: () => pickBirthdayDate(
                      context: context,
                      onDateTimeChanged: (dateTime) {
                        setState(() {
                          birthDayController.text =
                              '${dateTime.month}/${dateTime.day}/${dateTime.year}';
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                MyElevatedButton(
                  onPressed: () {
                    if (myAlueController.text.trim().isNotEmpty &&
                        mySchoolController.text.trim().isNotEmpty &&
                        birthDayController.text.isNotEmpty &&
                        selectedLanguages.isNotEmpty) {
                      widget.user.userBirthday = birthDayController.text;
                      widget.user.userArea = myAlueController.text.trim();
                      widget.user.userSchool = mySchoolController.text;
                      widget.user.userGender = genderToString(selectedGender);
                      widget.user.userLanguages = selectedLanguages;

                      widget.onUserDataChanged(widget.user);

                      widget.controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.linear,
                      );
                    } else {
                      showSnackBar(context,
                          'Varmista, että täytät kaikki tyhjät kohdat ja yritä uudeelleen!');
                    }
                  },
                  child: Text("Seuraava", style: Styles.bodyTextStyle),
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
