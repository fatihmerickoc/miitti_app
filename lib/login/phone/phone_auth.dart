import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_customTextField.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/constants/constants_widgets.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  late FocusNode myFocusNode;

  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void sendPhoneNumberToFirebase(AuthProvider authProvider) {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber[0] == '0') {
      // Remove the first character of the phone so  it is in this format +358449759068
      phoneNumber = phoneNumber.substring(1);
    }
    authProvider.signInWithPhone(context, "+358$phoneNumber");
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstantStyles().gapH50,
              Center(child: ConstantsWidgets().getMiittiLogo()),

              const Spacer(),

              Text(
                'Mikä on puhelinnumerosi?',
                style: ConstantStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              ConstantStyles().gapH20,

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 60.w,
                  decoration: const BoxDecoration(
                    color: ConstantStyles.pink,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 13.h,
                  ),
                  child: Text(
                    '+358',
                    textAlign: TextAlign.center,
                    style: ConstantStyles.hintText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: ConstantsCustomTextField(
                  hintText: '453301000',
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  focusNode: myFocusNode,
                ),
              ),

              ConstantStyles().gapH8,

              Text(
                'Lähetämme hetken kuluttua vahvistuskoodin sisältävän tekstiviestin.',
                style: ConstantStyles.warning,
              ),

              const Spacer(),

              ConstantsCustomButton(
                buttonText: 'Seuraava',
                onPressed: () {
                  if (phoneController.text.trim().isNotEmpty) {
                    sendPhoneNumberToFirebase(ap);
                  } else {
                    showSnackBar(
                        context,
                        'Huom! Sinun täytyy antaa puhelinnumerosi kirjautuaksesi sisään.',
                        ConstantStyles.red);
                  }
                },
              ), //Removed extra padding in ConstantsCustomButton
              ConstantStyles().gapH10,

              ConstantsCustomButton(
                buttonText: 'Takaisin',
                isWhiteButton: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              if (myFocusNode.hasFocus) ConstantStyles().gapH20
            ],
          ),
        ),
      ),
    );
  }
}
