import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/helpers/confirmdialog.dart';
import 'package:miitti_app/home.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
          color: Colors.white,
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
        color: Colors.white,
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
                        (value) => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (Route<dynamic> route) => false),
                      ),
                  child: createText('Kirjaudu ulos')),
              GestureDetector(
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
                        if (value) {
                          showSnackBar(
                            context,
                            'Tilisi on poistettu onnistuneesti!',
                            Colors.green.shade800,
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                              (Route<dynamic> route) => false);
                        } else {
                          showSnackBar(
                            context,
                            'Tilin poistaminen epäonnistui. Ole yhteydessä tukeen!',
                            Colors.red.shade800,
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
              createText('1.2.8'),
            ],
          ),
        ),
      ),
    );
  }
}
