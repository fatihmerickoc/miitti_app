import 'package:flutter/material.dart';

import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/constants/constants_widgets.dart';
import 'package:miitti_app/login/login_auth.dart';

class LoginIntro extends StatelessWidget {
  const LoginIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            ConstantsWidgets().getMiittiLogo(),
            ConstantStyles().gapH15,
            Text(
              'Tervetuloa! Aloitetaan matkasi kohti yhteisöllisempää \nhuomista!',
              textAlign: TextAlign.center,
              style: ConstantStyles.title,
            ),
            const Spacer(),
            ConstantsCustomButton(
              buttonText: 'Aloitetaan!',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginAuth()),
                  (Route<dynamic> route) =>
                      false, // Keep this false to remove all routes
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
