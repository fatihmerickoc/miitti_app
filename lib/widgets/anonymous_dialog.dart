import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/widgets/custom_button.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/screens/login/completeProfile/complete_profile_onboard.dart';
import 'package:miitti_app/utils/utils.dart';

class AnonymousDialog extends StatelessWidget {
  const AnonymousDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                color: ConstantStyles.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  children: [
                    const Divider(
                      color: Colors.white,
                      thickness: 2.0,
                      indent: 100,
                      endIndent: 100,
                    ),
                    Text(
                      'Hups!',
                      style: ConstantStyles.title,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'Näyttää siltä, ettet ole vielä viimeistellyt profiiliasi, joten et voi käyttää vielä\n sovelluksen kaikkia ominaisuuksia.\n\n Korjataanko asia?',
                        style: ConstantStyles.body,
                      ),
                    ),
                    getSomeSpace(10),
                    CustomButton(
                      buttonText: 'Viimeistele profiili',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CompleteProfileOnboard()));
                      },
                    ), //Removed extra padding in ConstantsCustomButton
                    ConstantStyles().gapH10,
                    CustomButton(
                      buttonText: 'Ei vielä',
                      isWhiteButton: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ), //Removed extra padding in ConstantsCustomButton
                    getSomeSpace(10.h),
                    Text(
                      'Voit myös viimeistellä profiilisi myöhemmin asetussivulla!',
                      style: ConstantStyles.warning,
                    ),
                    getSomeSpace(10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
