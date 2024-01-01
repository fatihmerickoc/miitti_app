import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miitti_app/adminPanel/admin_homePage.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminUserInfo extends StatefulWidget {
  final MiittiUser user;
  const AdminUserInfo({required this.user, super.key});

  @override
  State<AdminUserInfo> createState() => _AdminUserInfoState();
}

class _AdminUserInfoState extends State<AdminUserInfo> {
  String userLastOpenDate = "";

  @override
  void initState() {
    userLastOpenDate = widget.user.userStatus.isEmpty
        ? ''
        : DateFormat('MMMM d, HH:mm')
            .format(DateTime.tryParse(widget.user.userStatus)!);
    super.initState();
  }

  //Creates 3 of the purple info boxes
  Widget createPurpleBox(
      String title, String mainText, BuildContext context, bool isCopy) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      height: 100.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.purpleColor,
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          mainText,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isCopy
            ? Icon(
                Icons.copy,
                size: 20.sp,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget getRichText(String normalText, String boldedText) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: normalText,
            style: TextStyle(fontSize: 15.sp),
          ),
          TextSpan(
            text: boldedText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }

  Widget getListTileButton(Color mainColor, String text, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(15.w),
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> deleteUser() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    await ap.removeUser(widget.user.uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Käyttäjän poistaminen onnistui!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AdminHomePage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 40.h),
                  height: 60.h,
                  width: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.lightRedColor,
                        AppColors.orangeColor,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30.r,
                  ),
                ),
              ),
              Text(
                'Käyttäjätiedot',
                style: TextStyle(
                  fontSize: 20.sp,
                ),
              ),
              createPurpleBox('Etunimi', widget.user.userName, context, false),
              createPurpleBox(
                  'Sähköposti', widget.user.userEmail, context, true),
              createPurpleBox(
                  'Puhelinnumero', widget.user.userPhoneNumber, context, true),
              getRichText('Ollut viimeksi aktiivisena:  ', userLastOpenDate),
              SizedBox(height: 5.h),
              getRichText('Käytössä oleva sovellusversio:  ', '1.9'),
              const Expanded(child: SizedBox()),
              getListTileButton(
                AppColors.lightRedColor,
                'Poista käyttäjätili',
                () => deleteUser(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
