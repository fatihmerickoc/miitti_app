import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miitti_app/constants/constants_styles.dart';

class ConstantsWidgets {
  Widget getMiittiLogo() {
    return SvgPicture.asset(
      'images/miittiLogo.svg',
    );
  }

  Widget createAuthButton(
      {required bool isApple, required Function() onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isApple
                ? Icon(
                    Icons.apple,
                    size: 30.sp,
                  )
                : SvgPicture.asset(
                    'images/googleIcon.svg',
                  ),
            Text(
              isApple
                  ? 'Kirjaudu käyttäen Apple ID:tä'
                  : 'Kirjaudu käyttäen Googlea',
              textAlign: TextAlign.center,
              style: ConstantStyles.body
                  .copyWith(fontWeight: FontWeight.w700)
                  .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget createPinkDivider(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: ConstantStyles.pink,
            thickness: 2.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            text,
            style: ConstantStyles.body.copyWith(
              color: ConstantStyles.pink,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: ConstantStyles.pink,
            thickness: 2.0,
          ),
        ),
      ],
    );
  }

  bool emailValidator(String email) {
    final RegExp emailRegExp = RegExp(
        r"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)*");
    if (emailRegExp.hasMatch(email)) {
      return true;
    }
    return false;
  }

  Future<dynamic> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: ((context) {
        return const Center(
          child: CircularProgressIndicator(
            color: ConstantStyles.white,
          ),
        );
      }),
    );
    ;
  }
}
