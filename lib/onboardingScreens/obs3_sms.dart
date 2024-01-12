// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/onboardingScreens/onboarding.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OnBordingScreenSms extends StatefulWidget {
  final String verificationId;

  const OnBordingScreenSms({required this.verificationId, super.key});

  @override
  State<OnBordingScreenSms> createState() => _OnBordingScreenSmsState();
}

class _OnBordingScreenSmsState extends State<OnBordingScreenSms> {
  final _smsCodeFocusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    // TODO: implement dispose
    _smsCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              getMiittiLogo(),
              getGraphicImages('sms'),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Hetki, saat tuota pikaa vahvistuskoodin tekstiviestillä',
                  textAlign: TextAlign.center,
                  style: Styles.titleTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Pinput(
                  focusNode: _smsCodeFocusNode,
                  onTap: () {
                    if (_smsCodeFocusNode.hasFocus) {
                      _smsCodeFocusNode.unfocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 100.w,
                    height: 70.h,
                    textStyle: Styles.titleTextStyle,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1.5,
                          color: AppColors.purpleColor,
                        )),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      otpCode = value;
                    });
                    if (otpCode != null) {
                      verifyOtp(context, otpCode!);
                    } else {
                      showSnackBar(
                          context,
                          'SMS koodi on tyhjä, yritä uudelleen!',
                          Colors.red.shade800);
                    }
                  },
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              MyElevatedButton(
                onPressed: () {
                  if (otpCode != null) {
                    verifyOtp(context, otpCode!);
                  } else {
                    showSnackBar(
                        context,
                        'SMS koodi on tyhjä, yritä uudelleen!',
                        Colors.red.shade800);
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        "Vahvista puhelinnumero",
                        style: Styles.bodyTextStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: () {
          ap.checkExistingUser().then((value) async {
            if (value == true) {
              ap.getDataFromFirestore().then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.of(context)
                                    .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => IndexPage()),
                                        (Route<dynamic> route) => false),
                              ),
                        ),
                  );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  (Route<dynamic> route) => false);
            }
          });
        });
  }
}
