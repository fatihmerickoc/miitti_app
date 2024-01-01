// ignore_for_file: prefer_const_constructors, unused_local_variable, use_key_in_widget_constructors, unused_field, unnecessary_null_comparison, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/helpers/activity.dart';

import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/push_notifications.dart';
import 'package:miitti_app/questionAnswer.dart';
import 'package:miitti_app/utils/utils.dart';

import 'package:provider/provider.dart';

import 'index_page.dart';
import 'widgets/myElevatedButton.dart';

class MyProfileEditForm extends StatefulWidget {
  const MyProfileEditForm({required this.user, super.key});

  final MiittiUser user;

  @override
  _MyProfileEditFormState createState() => _MyProfileEditFormState();
}

class _MyProfileEditFormState extends State<MyProfileEditForm> {
  Color miittiColor = Color.fromRGBO(255, 136, 27, 1);

  final _formKey = GlobalKey<FormState>();

  TextEditingController userAreaController = TextEditingController();
  final userAreaFocusNode = FocusNode();

  TextEditingController userSchoolController = TextEditingController();
  final userSchoolFocusNode = FocusNode();

  File? image;

  Set<String> selectedLanguages = {};

  Map<String, String> userChoices = {};

  List<Activity> filteredActivities = [];
  List<Activity> favoriteActivities = [];

  @override
  void initState() {
    super.initState();
    filteredActivities = List.from(activities);
    favoriteActivities = activities
        .where((activity) =>
            widget.user.userFavoriteActivities.contains(activity.name))
        .toList();

    selectedLanguages = widget.user.userLanguages;
    userAreaController.text = widget.user.userArea;
    userSchoolController.text = widget.user.userSchool;
    userChoices = widget.user.userChoices;
  }

  @override
  void dispose() {
    userAreaController.dispose();
    userSchoolController.dispose();
    userAreaFocusNode.dispose();
    userSchoolFocusNode.dispose();
    super.dispose();
  }

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  void _toggleFavoriteActivity(Activity activity) {
    setState(() {
      if (favoriteActivities.contains(activity)) {
        favoriteActivities.remove(activity);
      } else {
        if (favoriteActivities.length < 5) {
          favoriteActivities.add(activity);
        }
      }
    });
  }

  void capitalizeInput() {
    final originalText = userAreaController.text;
    if (originalText.isNotEmpty) {
      final capitalizedText =
          originalText[0].toUpperCase() + originalText.substring(1);
      if (capitalizedText != originalText) {
        userAreaController.value = userAreaController.value.copyWith(
          text: capitalizedText,
          selection: TextSelection.collapsed(offset: capitalizedText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    List<String> answeredQuestions = questionOrder
        .where((question) => userChoices.containsKey(question))
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.w),
        child: AppBar(
          backgroundColor: AppColors.wineColor,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Muokkaa profiilia',
                    style: TextStyle(
                      fontSize: 27.sp,
                      fontFamily: 'Sora',
                      color: Colors.white,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.settings,
                      size: 30.r,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              InkWell(
                onTap: () {
                  selectImage();
                },
                child: Card(
                  elevation: 4,
                  color: miittiColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: image == null
                            ? Image.network(
                                ap.miittiUser.profilePicture,
                                height: 400.h,
                                width: 400.w,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                image!,
                                height: 400.h,
                                width: 400.w,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              getSections(
                title: 'Missä asustelet',
                subtitle:
                    'Emme tunge kylään, mutta näin osaamme ehdottaa sopiva miittejä alueellasi',
                mainWidget: getOurTextField(
                  myPadding: EdgeInsets.only(right: 10.w),
                  myController: userAreaController,
                  myFocusNode: userAreaFocusNode,
                  myOnChanged: (_) => capitalizeInput(),
                  myOnTap: () {
                    if (userAreaFocusNode.hasFocus) {
                      userAreaFocusNode.unfocus();
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
                  myController: userSchoolController,
                  myFocusNode: userSchoolFocusNode,
                  myOnChanged: (_) => capitalizeInput(),
                  myOnTap: () {
                    if (userSchoolFocusNode.hasFocus) {
                      userSchoolFocusNode.unfocus();
                    }
                  },
                  myKeyboardType: TextInputType.streetAddress,
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
              SizedBox(
                height: 20.h,
              ),
              createSection(
                textTitle: 'Lisää lempiaktiviteettisi',
                textSubtitle:
                    'Valitse vähintään 3 lempiaktiviteettisi, mitä haluaisit tehdä muiden kanssa',
                secondWidget: SizedBox(
                  height: 400.h,
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
                                activity.emojiData,
                                style: TextStyle(fontSize: 50.0.sp),
                              ),
                              Text(
                                activity.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 19.0.sp,
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
              createDifferentSection(
                textTitle: 'Esittele itsesi',
                textSubtitle:
                    'Valitse 1-5 Q&A korttia, joiden avulla voit kertoa itsestäsi enemmän',
                inputWidget: userChoices.isNotEmpty
                    ? SizedBox(
                        height: 200.w,
                        child: PageView.builder(
                          itemCount: userChoices.length,
                          itemBuilder: (context, index) {
                            String question = answeredQuestions[index];
                            String answer = userChoices[question]!;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5.0,
                              child: Container(
                                padding: EdgeInsets.all(15.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.purpleColor,
                                        fontSize: 22.0.sp,
                                        fontFamily: 'Sora',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    Text(
                                      answer,
                                      maxLines: 4,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Rubik',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 200.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightRedColor,
                              AppColors.orangeColor,
                            ],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              Map<String, String>? result =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuestionAnswer(
                                    recievedData: null,
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(
                                  () {
                                    userChoices = result;
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.orangeColor,
                                    AppColors.lightRedColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 35.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                secondWidget: userChoices.isNotEmpty
                    ? Center(
                        child: MyElevatedButton(
                          width: 225.w,
                          height: 45.w,
                          onPressed: () async {
                            Map<String, String>? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionAnswer(
                                  recievedData: userChoices,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(
                                () {
                                  userChoices = result;
                                },
                              );
                            }
                          },
                          child: Text(
                            "+ Lisää uusi Q&A",
                            style: TextStyle(
                              fontSize: 17.0.sp,
                              fontFamily: 'Rubik',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
              MyElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      userAreaController.text.trim().isNotEmpty &&
                      userSchoolController.text.trim().isNotEmpty &&
                      selectedLanguages.isNotEmpty &&
                      userChoices.isNotEmpty &&
                      favoriteActivities.length >= 3) {
                    _formKey.currentState!.save();

                    final updatedUser = MiittiUser(
                        userName: ap.miittiUser.userName,
                        userEmail: ap.miittiUser.userEmail,
                        uid: ap.miittiUser.uid,
                        userPhoneNumber: ap.miittiUser.userPhoneNumber,
                        userBirthday: ap.miittiUser.userBirthday,
                        userArea: userAreaController.text.trim(),
                        userFavoriteActivities: favoriteActivities
                            .map((activity) => activity.name)
                            .toSet(),
                        userChoices: userChoices,
                        userGender: ap.miittiUser.userGender,
                        profilePicture: ap.miittiUser.profilePicture,
                        userLanguages: selectedLanguages,
                        invitedActivities: ap.miittiUser.invitedActivities,
                        userStatus: ap.miittiUser.userStatus,
                        userSchool: userSchoolController.text,
                        fcmToken: ap.miittiUser.fcmToken);
                    await ap.updateUserInfo(updatedUser, image).then((value) {
                      ap
                          .saveUserDataToSP()
                          .then((value) => ap.setSignIn().then((value) {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => IndexPage(
                                              initialPage: 3,
                                            )),
                                    (Route<dynamic> route) => false);
                              }));
                    });
                  } else {
                    showSnackBar(context,
                        'Varmista, että täytät kaikki tyhjät kohdat ja yritä uudeelleen!');
                  }
                },
                child: isLoading == true
                    ? CircularProgressIndicator(
                        color: AppColors.lightPurpleColor,
                      )
                    : Text(
                        'Tallenna muutokset',
                        style: Styles.bodyTextStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget returnTexts(String? bigText, String? smallText, bool isBigText) {
    if (isBigText) {
      return Padding(
        padding: EdgeInsets.only(top: 20.0.h, bottom: 5.0.h),
        child: Text(
          bigText!,
          style: TextStyle(
            fontSize: 20.0.sp,
            fontFamily: 'Sora',
            fontWeight: FontWeight.bold,
            color: miittiColor,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 15.0.h),
        child: Text(
          smallText!,
          style: TextStyle(
            fontSize: 13.0.sp,
            fontFamily: 'Sora',
            color: miittiColor,
          ),
        ),
      );
    }
  }

  Widget createSection({
    required String textTitle,
    required String textSubtitle,
    required Widget secondWidget,
  }) {
    return Column(
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
        secondWidget,
        SizedBox(
          height: 30.h,
        ),
      ],
    );
  }

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
        height: 65.w,
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

  Widget createDifferentSection({
    required String textTitle,
    required String textSubtitle,
    required Widget inputWidget,
    required Widget secondWidget,
  }) {
    return Column(
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
    );
  }
}
