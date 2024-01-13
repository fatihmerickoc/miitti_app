// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/questionAnswer.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';
import '../constants/miittiUser.dart';

class OnBoardingScreenQA extends StatefulWidget {
  OnBoardingScreenQA(
      {required this.controller,
      required this.onUserDataChanged,
      required this.user,
      super.key});

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  PageController controller;

  @override
  State<OnBoardingScreenQA> createState() => _OnBoardingScreenQAState();
}

class _OnBoardingScreenQAState extends State<OnBoardingScreenQA> {
  bool isSelected = false;

  Map<String, String> userChoices = {};

  Widget createSection({
    required String textTitle,
    required String textSubtitle,
    required Widget inputWidget,
    required Widget secondWidget,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15.w,
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
  Widget build(BuildContext context) {
    List<String> answeredQuestions = questionOrder
        .where((question) => userChoices.containsKey(question))
        .toList();

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
                textTitle: 'Esittele itsesi',
                textSubtitle:
                    'Valitse 1-5 Q&A korttia, joiden avulla voit kertoa itsestäsi enemmän',
                inputWidget: userChoices.isNotEmpty
                    ? SizedBox(
                        height: 200.h,
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
                                        fontSize: 22.sp,
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
                        height: 200.h,
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
                          height: 45.h,
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
                              fontSize: 17.sp,
                              fontFamily: 'Rubik',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
              createSection(
                textTitle: 'Millaista musiikkia kuuntelet',
                textSubtitle: 'Voit linkittää tähän Spotify -soittolistan',
                inputWidget: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(15.0.w),
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF1DB954),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          height: 40.h,
                          'images/spotify.png',
                        ),
                        Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                secondWidget: Container(),
              ),
              MyElevatedButton(
                onPressed: () {
                  if (userChoices.isNotEmpty) {
                    widget.user.userChoices = userChoices;
                    widget.onUserDataChanged(widget.user);
                    widget.controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                  } else {
                    showSnackBar(
                      context,
                      'Q&A kortti ei voi olla tyhjä, yritä uudelleen!',
                      Colors.red.shade800,
                    );
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
