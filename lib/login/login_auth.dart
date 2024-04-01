import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_customTextField.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/constants/constants_widgets.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginAuth extends StatefulWidget {
  const LoginAuth({super.key});

  @override
  State<LoginAuth> createState() => _LoginAuthState();
}

class _LoginAuthState extends State<LoginAuth> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendPhoneNumberToFirebase(AuthProvider authProvider) {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber[0] == '0') {
      // Remove the first character of the phone so  it is in this format +358449759068
      phoneNumber = phoneNumber.substring(1);
    }
    authProvider.signInWithPhone(context, "+358$phoneNumber");
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstantStyles().gapH50,

                //miitti-logo
                Center(child: ConstantsWidgets().getMiittiLogo()),

                ConstantStyles().gapH50,

                //welcome title
                Text(
                  'Tervetuloa!',
                  style: ConstantStyles.title,
                ),

                //welcome subtitle
                Text(
                  'Aloitetaan matkasi kohti yhteisöllisempää huomista!',
                  style: ConstantStyles.body,
                ),

                ConstantStyles().gapH10,

                //apple sign in
                Platform.isIOS
                    ? ConstantsWidgets().createAuthButton(
                        isApple: true,
                        onPressed: () {
                          //handle apple sign-in
                          ap.signInWithApple(context);
                        },
                      )
                    : Container(),

                ConstantStyles().gapH10,

                //google sign in
                ConstantsWidgets().createAuthButton(
                  isApple: false,
                  onPressed: () {
                    //handle google sign-in
                    ap.signInWithGoogle(context);
                  },
                ),

                ConstantStyles().gapH15,

                //pink divider
                ConstantsWidgets().createPinkDivider('Tai'),

                //textformfield title
                Text(
                  'Puhelinnumero',
                  style: ConstantStyles.textField,
                ),

                //custom textformfield
                ConstantsCustomTextField(
                  hintText: 'esim. 0449759068',
                  controller: phoneController,
                ),

                SizedBox(
                  height: 160.h,
                ),

                //privacy agreement text
                Center(
                  child: GestureDetector(
                    onTap: () {
                      launchUrlString('https://www.miitti.app/kayttoehdot');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: ConstantStyles.warning,
                        children: const <TextSpan>[
                          TextSpan(
                              text:
                                  'Kirjautumalla sisään hyväksyt sovelluksen '),
                          TextSpan(
                            text: 'käyttöehdot',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                ConstantStyles().gapH10,

                //continue custom button
                ConstantsCustomButton(
                  buttonText: 'Seuraava',
                  onPressed: () {
                    if (phoneController.text.trim().isNotEmpty) {
                      sendPhoneNumberToFirebase(ap);
                    } else {
                      showSnackBar(
                          context,
                          'Huom! Sinun täytyy antaa puhelinnumerosi kirjautuaksesi sisään.',
                          ConstantStyles.red);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
