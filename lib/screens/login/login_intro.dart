//TODO: Refactor

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants.dart';

import 'package:miitti_app/widgets/custom_button.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/widgets/other_widgets.dart';
import 'package:miitti_app/screens/login/login_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginIntro extends StatelessWidget {
  const LoginIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //background gif with 0.8 opacity purple
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  "images/splashscreen.gif",
                ),
                colorFilter: ColorFilter.mode(
                  AppColors.backgroundColor.withOpacity(0.2),
                  BlendMode.dstATop,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              OtherWidgets().getMiittiLogo(),
              ConstantStyles().gapH15,
              Text(
                'Upgreidaa sosiaalinen elämäsi',
                textAlign: TextAlign.center,
                style: ConstantStyles.body,
              ),
              const Spacer(),
              CustomButton(
                buttonText: 'Aloitetaan!',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginAuth()),
                  );
                },
              ),
              ConstantStyles().gapH8,
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: ConstantStyles.warning,
                  children: <TextSpan>[
                    const TextSpan(
                        text:
                            'Ottamalla Miitti App -sovelluksen käyttöön hyväksyt samalla voimassaolevan '),
                    TextSpan(
                      text: 'tietosuojaselosteen',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(
                            'https://www.miitti.app/tietosuojaseloste'),
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' sekä '),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(
                            'https://www.miitti.app/kayttoehdot'),
                      text: 'käyttöehdot',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OtherWidgets().getLanguagesButtons(),
            ],
          ),
        ],
      ),
    );
  }
}
