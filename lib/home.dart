// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/adminPanel/admin_homePage.dart';
import 'package:miitti_app/adminPanel/admin_signIn.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/onboardingScreens/obs2_phone.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getMiittiLogo(),
            getGraphicImages('people'),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                "Onpa hauska nähdä, tervetuloa Miittiin 🤗",
                textAlign: TextAlign.center,
                style: Styles.titleTextStyle,
              ),
            ),
            MyElevatedButton(
              onPressed: () async {
                if (ap.isSignedIn == true) {
                  await ap.getDataFromSp().whenComplete(
                        () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => IndexPage()),
                        ),
                      );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => OnBoardingScreenPhone()),
                  );
                }
              },
              child: Text(
                "Rekisteröidy",
                style: Styles.bodyTextStyle,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            GestureDetector(
              onTap: () async {
                if (ap.isSignedIn == true) {
                  await ap.getDataFromSp().whenComplete(
                        () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => IndexPage()),
                        ),
                      );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => OnBoardingScreenPhone()),
                  );
                }
              },
              child: Text(
                "Kirjaudu sisään",
                style: Styles.bodyTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
