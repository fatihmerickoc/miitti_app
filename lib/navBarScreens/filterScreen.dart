// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/helpers/confirmdialog.dart';
import 'package:miitti_app/home.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool allowNotifications = true;

  Widget getMyContainer(
    String title,
  ) {
    return Container(
      height: 130.h,
      margin: EdgeInsets.all(8.0.w),
      padding: EdgeInsets.all(10.0.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            AppColors.lightRedColor,
            AppColors.orangeColor,
          ],
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Rubik',
          color: Colors.white,
          fontSize: 19.sp,
        ),
      ),
    );
  }

  void toggleSwitch(bool value) {
    setState(() {
      allowNotifications = !allowNotifications;
    });
  }

  Widget getMyTextCombo(
      String titleText, List<String> underlineTexts, List<String> urls) {
    final Uri url0 = Uri.parse(urls[0]);
    final Uri url1 = Uri.parse(urls[1]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            titleText,
            style: TextStyle(
              fontSize: 19.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        GestureDetector(
          onTap: () async {
            if (!await launchUrl(url0)) {
              throw Exception('Could not launch $url0');
            }
          },
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text(
              underlineTexts[0],
              style: TextStyle(
                fontSize: 18.sp,
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        GestureDetector(
          onTap: () async {
            if (!await launchUrl(url1)) {
              throw Exception('Could not launch $url1');
            }
          },
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text(
              underlineTexts[1],
              style: TextStyle(
                fontSize: 18.sp,
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: getMyContainer('Omat tilastot')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: getMyContainer('Omat tietosi'),
                ),
                Expanded(
                  flex: 2,
                  child: getMyContainer(
                    'Ota yhteyttä chat-tukipalveluumme',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Text(
                    'Salli Push-ilmoitukset',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
                Switch(
                  value: allowNotifications,
                  onChanged: toggleSwitch,
                  activeColor: AppColors.purpleColor,
                  activeTrackColor: AppColors.lightPurpleColor,
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            getMyTextCombo(
              'Asiakaspalvelun yhteystiedot',
              [
                'Seuraa meitä Instagramissa',
                'info@miitti.app',
              ],
              [
                'https://www.instagram.com/miittiapp/',
                'https://www.miitti.app/yhteystiedot',
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            getMyTextCombo(
              'Sovelluksen käyttöehdot & tietosuojaseloste',
              [
                'Lue sovelluksen käyttöehdot ja yhteisönormit',
                'Tutustu tietosuojaselosteeseen',
              ],
              [
                'https://uploads-ssl.webflow.com/6422df7a53cbcfb3ddc62a00/643a77c48248566559991c21_Miitti%20App%20-%20tietosuojaseloste.pdf',
                'https://uploads-ssl.webflow.com/6422df7a53cbcfb3ddc62a00/643a77c48248566559991c21_Miitti%20App%20-%20tietosuojaseloste.pdf',
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmDialog(
                      title: 'Varmistus',
                      mainText:
                          'Oletko varma, että haluat poistaa? Jos valitset Poista, poistamme tilisi palvelimeltamme. Myös sovellustietosi poistetaan, etkä voi palauttaa niitä.',
                    );
                  },
                ).then((confirmed) {
                  if (confirmed != null && confirmed) {
                    print("MERHABA");
                    ap.removeUser(ap.miittiUser.uid).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Tilisi on poistettu onnistuneesti'),
                        backgroundColor: Colors.green.shade800,
                      ));
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false);
                    });
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Text(
                  'Poista tili',
                  style: TextStyle(
                    fontSize: 19.sp,
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                '1.1.9',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: Colors.white,
                  fontFamily: 'Rubik',
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: MyElevatedButton(
                height: 50.w,
                width: 200.w,
                onPressed: () {
                  ap.userSignOut().then((value) => Navigator.of(context)
                      .pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false));
                },
                child: Text(
                  'Kirjaudu ulos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0.sp,
                    fontFamily: 'Rubik',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
