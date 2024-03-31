import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants_styles.dart';

class ConstantsAnonymousUser extends StatelessWidget {
  const ConstantsAnonymousUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Et ole vielä viimeistellyt profiiliasi, joten\n et voi käyttää vielä sovelluksen kaikkia ominaisuuksia.',
          style: ConstantStyles.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
