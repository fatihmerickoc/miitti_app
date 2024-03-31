// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'constants/miittiUser.dart';

class PrivacyAgreement extends StatefulWidget {
  const PrivacyAgreement({required this.user, required this.image, super.key});

  final MiittiUser user;
  final File? image;

  @override
  State<PrivacyAgreement> createState() => _PrivacyAgreementState();
}

class _PrivacyAgreementState extends State<PrivacyAgreement> {
  Map<String, dynamic> userPrefs = {
    'sameGender': false,
    'multiplePeople': true,
    'ageLimitBeginning': 18.0,
    'ageLimitEnd': 60.0,
    'maxDistance': 50.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50.h,
              ),
              Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Text(
                  "Tervetuloa mukaan,",
                  style: Styles.titleTextStyle,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(3.0.w),
                child: Text(
                  "Tässä keskeiset yhteisönormimme, joita noudattamalla pidät alustan turvallisena ja ystävällisenä kaikille. 💜",
                  textAlign: TextAlign.center,
                  style: Styles.sectionSubtitleStyle,
                ),
              ),
              SizedBox(
                height: 20.0.h,
              ),
              createListTile(
                'Kohtelen muita ystävällisesti ja kunnioittaen',
              ),
              createListTile(
                'Miitti ei ole deittisovellus, tutustun muihin ihmisiin ainoastaan kaverimielessä',
              ),
              createListTile(
                'En syrji muita tai jätä ketään tarkoituksellisesti porukan ulkopuolelle',
              ),
              createListTile(
                'Puutun kiusamiseen tai muuhun epätavalliseen käytökseen',
              ),
              createListTile(
                'Käännyn aina tarvittaessa ylläpidon puoleen',
              ),
              SizedBox(
                height: 80.h,
              ),
              MyElevatedButton(
                  onPressed: () => storeData(context),
                  child: Text(
                    "Hyväksy",
                    style: Styles.bodyTextStyle,
                  )),
              Padding(
                padding: EdgeInsets.all(5.0.w),
                child: Text(
                  "Ottamalla palvelun käyttöön hyväksyt käyttöehdot yhteisönormit sekä tietosuojaselosteet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void storeData(BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (ap.isAnonymous) {
      ap
          .updateUserInfo(
            updatedUser: widget.user,
            imageFile: widget.image,
            context: context,
          )
          .then(
            (value) => ap.saveUserDataToSP().then(
                  (value) => ap.setSignIn().then(
                        (value) => ap.setAnonymousModeOf().then(
                              (value) => pushNRemoveUntil(
                                context,
                                IndexPage(),
                              ),
                            ),
                      ),
                ),
          );
    } else {
      ap.saveUserDatatoFirebase(
        context: context,
        userModel: widget.user,
        image: widget.image,
        onSucess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                  (value) {
                    pushNRemoveUntil(context, IndexPage());
                  },
                ),
              );
        },
      );
    }
  }
}
