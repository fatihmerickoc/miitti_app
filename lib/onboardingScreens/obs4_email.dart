// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';

import '../constants/miittiUser.dart';

class OnBoardingScreenEmail extends StatefulWidget {
  OnBoardingScreenEmail(
      {required this.controller,
      required this.user,
      required this.onUserDataChanged,
      super.key});

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  PageController controller;

  @override
  State<OnBoardingScreenEmail> createState() => _OnBoardingScreenEmailState();
}

class _OnBoardingScreenEmailState extends State<OnBoardingScreenEmail> {
  final emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.user.userEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              getMiittiLogo(),
              getGraphicImages('email'),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Lisääthän vielä sähköpostiosoitteesi',
                  textAlign: TextAlign.center,
                  style: Styles.titleTextStyle,
                ),
              ),
              getOurTextField(
                myPadding: EdgeInsets.all(15.w),
                myFocusNode: _emailFocusNode,
                myOnTap: () {
                  if (_emailFocusNode.hasFocus) {
                    _emailFocusNode.unfocus();
                  }
                },
                myController: emailController,
                myKeyboardType: TextInputType.emailAddress,
              ),
              MyElevatedButton(
                onPressed: () {
                  final bool isValid =
                      EmailValidator.validate(emailController.text);
                  if (isValid) {
                    widget.user.userEmail = emailController.text.trim();
                    widget.onUserDataChanged(widget.user);
                    widget.controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                  } else {
                    showSnackBar(
                        context,
                        'Sähköposti on tyhjä tai se on väärässä muodossa!',
                        Colors.red.shade800);
                  }
                },
                child: Text(
                  "Seuraava",
                  style: Styles.bodyTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
