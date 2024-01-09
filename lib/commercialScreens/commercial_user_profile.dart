// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/commercial_user.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/push_notifications.dart';

import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommercialProfileScreen extends StatefulWidget {
  final CommercialUser user;
  final bool? comingFromAdmin;
  const CommercialProfileScreen(
      {required this.user, this.comingFromAdmin, super.key});

  @override
  State<CommercialProfileScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<CommercialProfileScreen> {
  Color miittiColor = Color.fromRGBO(255, 136, 27, 1);

  @override
  void initState() {
    super.initState();
    //Initialize the list from given data
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          backgroundColor: AppColors.wineColor,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Image.network(
                    widget.user.profilePicture,
                    height: 400.h,
                    width: 400.w,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: miittiColor,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.lightRedColor,
                            AppColors.orangeColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: InkWell(
                child: Text(
                  widget.user.linkTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 17.0.sp,
                    color: AppColors.lightPurpleColor,
                  ),
                ),
                onTap: () async {
                  await launchUrl(Uri.parse(widget.user.hyperlink));
                }),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Text(
              widget.user.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 17.0.sp,
                color: AppColors.whiteColor,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
