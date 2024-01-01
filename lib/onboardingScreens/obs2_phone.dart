// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';

class OnBoardingScreenPhone extends StatefulWidget {
  const OnBoardingScreenPhone({super.key});

  @override
  State<OnBoardingScreenPhone> createState() => _OnBoardingScreenPhoneState();
}

class _OnBoardingScreenPhoneState extends State<OnBoardingScreenPhone> {
  TextEditingController phoneController = TextEditingController();
  final _phoneNumberFocusNode = FocusNode();
  bool isPhoneNumberValid = false;

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    phoneController.dispose();
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
              getGraphicImages('menwithphone'),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Syötä puhelinnumerosi',
                  textAlign: TextAlign.center,
                  style: Styles.titleTextStyle,
                ),
              ),
              getOurTextField(
                myPadding: EdgeInsets.all(15.w),
                myFocusNode: _phoneNumberFocusNode,
                myController: phoneController,
                myOnChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty && value[0] == '0') {
                      // Remove the first character
                      value = value.substring(1);
                    }
                    isPhoneNumberValid = validatePhoneNumber("+358$value");
                    /*if (isPhoneNumberValid) {
                      //_phoneNumberFocusNode.unfocus();
                      //sendPhoneNumber();
                    }*/
                  });
                },
                myOnTap: () {
                  if (_phoneNumberFocusNode.hasFocus) {
                    _phoneNumberFocusNode.unfocus();
                  }
                },
                myKeyboardType: TextInputType.phone,
                myPrefixIcon: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 20.0.w),
                  child: Text(
                    "🇫🇮 +358",
                    style: Styles.bodyTextStyle,
                  ),
                ),
                mySuffixIcon: isPhoneNumberValid
                    ? Icon(
                        Icons.done,
                        color: Colors.green,
                        size: 30.0.sp,
                      )
                    : Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30.0.sp,
                      ),
              ),
              MyElevatedButton(
                onPressed: () {
                  if (isPhoneNumberValid) {
                    _phoneNumberFocusNode.unfocus();
                    sendPhoneNumber();
                  } else {
                    showSnackBar(
                      context,
                      'Puhelinnumero ei löydy tai se on väärä!',
                    );
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text("Seuraava", style: Styles.bodyTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isNotEmpty && phoneNumber[0] == '0') {
      // Remove the first character
      phoneNumber = phoneNumber.substring(1);
    }
    ap.signInWithPhone(context, "+358$phoneNumber");
  }
}
