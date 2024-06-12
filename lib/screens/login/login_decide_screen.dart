//TODO: Refactor

import 'package:flutter/material.dart';
import 'package:miitti_app/widgets/custom_button.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/screens/index_page.dart';
import 'package:miitti_app/screens/login/completeProfile/complete_profile_onboard.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginDecideScreen extends StatelessWidget {
  const LoginDecideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: ap.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
                children: [
                  const Spacer(),
                  //title
                  Text(
                    'Tervetuloa Miittiin! 🎊',
                    textAlign: TextAlign.center,
                    style: ConstantStyles.title,
                  ),

                  //body
                  Text(
                    'Haluaisitko seuraavaksi suorittaa profiilin luonnin loppuun, vai tutustua\n sovellukseen?',
                    textAlign: TextAlign.center,
                    style: ConstantStyles.body,
                  ),

                  const Spacer(),

                  //continue building profile button
                  CustomButton(
                    buttonText: 'Jatka profiilin luomista',
                    onPressed: () {
                      //continue profile
                      pushNRemoveUntil(context, const CompleteProfileOnboard());
                    },
                  ),

                  //get to know the app button
                  TextButton(
                    onPressed: () => pushNRemoveUntil(
                      context,
                      const IndexPage(),
                    ),
                    child: Text(
                      'Tutustu sovellukseen',
                      style: ConstantStyles.body,
                    ),
                  ),

                  //warning
                  Text(
                    'Huom! Kaikki sovelluksen ominaisuudet eivät ole käytettävissä,\n ennen kuin profiilisi on viimeistelty. ',
                    textAlign: TextAlign.center,
                    style: ConstantStyles.warning
                        .copyWith(color: ConstantStyles.red),
                  )
                ],
              ),
      ),
    );
  }
}
