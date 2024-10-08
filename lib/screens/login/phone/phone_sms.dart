import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/widgets/custom_button.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PhoneSms extends StatefulWidget {
  final String verificationId;
  const PhoneSms({required this.verificationId, super.key});

  @override
  State<PhoneSms> createState() => _PhoneSmsState();
}

class _PhoneSmsState extends State<PhoneSms> {
  late FocusNode smsFocusNode;
  String? smsCode;

  @override
  void initState() {
    super.initState();
    smsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    smsFocusNode.dispose();
    super.dispose();
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        ap.afterSigning(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              Text(
                'Syötä\nvahvistuskoodi',
                style: ConstantStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              ConstantStyles().gapH20,

              Pinput(
                focusNode: smsFocusNode,
                onTap: () {
                  if (smsFocusNode.hasFocus) {
                    smsFocusNode.unfocus();
                  }
                },
                keyboardType: TextInputType.number,
                length: 6,
                defaultPinTheme: PinTheme(
                  height: 60.h,
                  width: 45.w,
                  textStyle: ConstantStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(152, 28, 228, 0.10),
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.white),
                    ),
                  ),
                ),
                onCompleted: (value) {
                  setState(() {
                    smsCode = value;
                  });
                  verifyOtp(context, smsCode!);
                },
              ),
              ConstantStyles().gapH8,

              Text(
                'Syötä kuusinumeroinen vahvistuskoodi, jonka sait tekstiviestillä',
                style: ConstantStyles.warning,
              ),

              const Spacer(),

              CustomButton(
                buttonText: 'Seuraava',
                onPressed: () {
                  if (smsCode != null) {
                    verifyOtp(context, smsCode!);
                  } else {
                    showSnackBar(
                      context,
                      'SMS koodi on tyhjä, yritä uudelleen!',
                      ConstantStyles.red,
                    );
                  }
                },
              ), //Removed extra padding in ConstantsCustomButton
              ConstantStyles().gapH10,

              CustomButton(
                buttonText: 'Takaisin',
                isWhiteButton: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              if (smsFocusNode.hasFocus) ConstantStyles().gapH20
            ],
          ),
        ),
      ),
    );
  }
}
