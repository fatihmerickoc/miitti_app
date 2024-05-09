import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/confirmdialog.dart';
import 'package:miitti_app/screens/login/completeProfile/complete_profile_onboard.dart';
import 'package:miitti_app/screens/login/login_intro.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:miitti_app/cannyWebView.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.controller, super.key});

  final WebViewController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget createHyperLink(String text, String url) {
    return InkWell(
      onTap: () => launchUrlString(url),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.sp,
          fontFamily: 'Rubik',
          color: AppColors.lightPurpleColor,
        ),
      ),
    );
  }

  Widget createSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontFamily: 'Poppins',
        color: Colors.white,
      ),
    );
  }

  Widget createText(String text, {double fontSize = 17.0}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontFamily: 'Rubik',
        color: AppColors.lightPurpleColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asetukset',
                style: TextStyle(
                  fontSize: 35.sp,
                  color: Colors.white,
                  fontFamily: 'Sora',
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CannyWebView(
                        controller: widget.controller,
                        userEmail: ap.miittiUser.userEmail,
                        userName: ap.miittiUser.userName,
                        userId: ap.miittiUser.uid,
                        userAvatarURL: ap.miittiUser.profilePicture,
                        userCreated: ap.miittiUser.userRegistrationDate,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                      AppColors.mixGradientColor),
                  minimumSize: WidgetStateProperty.all<Size>(const Size(
                      double.infinity, 140)), // Makes the button 100% wide
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text vertically
                  children: [
                    Text(
                      'Anna palautetta',
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.white,
                      ), // Large text
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Ehdota uusia ominaisuuksia, ilmoita ongelmista tai liity keskusteluun parannusehdotuksista!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Rubik',
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Voit myös liittyä Discord kanavallemme ',
                    ),
                    TextSpan(
                      text: 'täällä',
                      style: TextStyle(
                        color: AppColors.lightPurpleColor,
                        fontFamily: 'Rubik',
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://discord.gg/TwPNwwad');
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              createSectionTitle('Asiakaspalvelun yhteystiedot'),
              createHyperLink(
                "Seuraa meitä Instagramissa",
                'https://www.instagram.com/miittiapp/',
              ),
              createHyperLink(
                "info@miitti.app",
                'https://mail.google.com/mail/u/0/?fs=1&tf=cm&source=mailto&su=Yhteydenotto+sovellukselta&to=touko@miitti.app',
              ),
              SizedBox(height: 20.h),
              createSectionTitle(
                'Sovelluksen käyttöehdot & tietosuojaselostet',
              ),
              createHyperLink(
                "Lue sovelluksen käyttöehdot",
                'https://www.miitti.app/kayttoehdot',
              ),
              createHyperLink(
                "Tutustu tietosuojaselosteeseen",
                'https://www.miitti.app/tietosuojaseloste',
              ),
              SizedBox(height: 20.h),
              createSectionTitle('Tilin asetukset'),
              GestureDetector(
                  onTap: () => ap.userSignOut().then(
                        (value) =>
                            pushNRemoveUntil(context, const LoginIntro()),
                      ),
                  child: createText('Kirjaudu ulos')),
              ap.isAnonymous
                  ? GestureDetector(
                      onTap: () {
                        pushNRemoveUntil(
                            context, const CompleteProfileOnboard());
                      },
                      child: createText('Viimeistele profiili'),
                    )
                  : GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const ConfirmDialog(
                              title: 'Varmistus',
                              mainText:
                                  'Oletko varma, että haluat poistaa tilisi? Tämä toimenpide on peruuttamaton, ja kaikki tietosi poistetaan pysyvästi.',
                            );
                          },
                        ).then((confirmed) {
                          if (confirmed != null && confirmed) {
                            ap.removeUser(ap.miittiUser.uid).then((value) {
                              showSnackBar(context, value.$2,
                                  value.$1 ? Colors.green : Colors.red);
                              if (value.$1) {
                                ap.userSignOut().then(
                                      (value) => pushNRemoveUntil(
                                          context, const LoginIntro()),
                                    );
                              }
                            });
                          }
                        });
                      },
                      child: createText('Poista tili'),
                    ),
              SizedBox(height: 20.h),
              createSectionTitle('Versio'),
              Text(
                '1.5.3',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: 'Rubik',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
