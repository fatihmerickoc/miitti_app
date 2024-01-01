// ignore_for_file: prefer_const_constructors, must_be_immutable, sort_child_properties_last
// 250 =  0.58 * screenWidth
// 17 =  0.04 * screenWidth
//
//
//

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';

class OnBoardingScreenName extends StatefulWidget {
  OnBoardingScreenName(
      {required this.controller,
      required this.user,
      required this.onUserDataChanged,
      super.key});

  final MiittiUser user;
  final Function(MiittiUser) onUserDataChanged;
  PageController controller;

  @override
  State<OnBoardingScreenName> createState() => _OnBoardingScreenNameState();
}

class _OnBoardingScreenNameState extends State<OnBoardingScreenName> {
  final nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.user.userName;
  }

  @override
  void dispose() {
    nameController.dispose();
    _nameFocusNode.dispose();

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
              getGraphicImages('new'),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Aloitetaan helpolla, kertoisitko ensin etunimesi?',
                  textAlign: TextAlign.center,
                  style: Styles.titleTextStyle,
                ),
              ),
              getOurTextField(
                myPadding: EdgeInsets.all(15.w),
                myFocusNode: _nameFocusNode,
                myOnTap: () {
                  if (_nameFocusNode.hasFocus) {
                    _nameFocusNode.unfocus();
                  }
                },
                myController: nameController,
                myKeyboardType: TextInputType.name,
              ),
              MyElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    widget.user.userName = nameController.text.trim();
                    widget.onUserDataChanged(widget.user);

                    widget.controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                  } else {
                    showSnackBar(
                        context, 'Nimi ei voi olla tyhjä, yritä uudeelleen');
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
