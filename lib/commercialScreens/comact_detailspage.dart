// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:miitti_app/commercialScreens/comchat_page.dart';
import 'package:miitti_app/commercialScreens/commercial_user_profile.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/commercial_user.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:miitti_app/userProfileEditScreen.dart';

import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/miittiUser.dart';

class ComActDetailsPage extends StatefulWidget {
  final bool? comingFromAdmin;

  ComActDetailsPage({
    required this.myActivity,
    this.comingFromAdmin,
    super.key,
  });

  CommercialActivity myActivity;

  @override
  State<ComActDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ComActDetailsPage> {
  late CameraPosition myCameraPosition;
  late MapboxMapController myController;

  bool isAlreadyJoined = false;

  CommercialUser? company;
  int participantCount = 0;
  List<MiittiUser> participantList = [];

  @override
  void initState() {
    super.initState();
    checkIfJoined();
    fetchAdmin();
    fetchUsersJoinedActivity();
    myCameraPosition = CameraPosition(
      target: LatLng(
        widget.myActivity.activityLati,
        widget.myActivity.activityLong,
      ),
      zoom: 15,
    );
  }

  _onMapCreated(MapboxMapController controller) {
    myController = controller;
  }

  _onStyleLoadedCallBack() {
    myController.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          widget.myActivity.activityLati,
          widget.myActivity.activityLong,
        ),
        iconImage:
            'images/${widget.myActivity.activityCategory.toLowerCase()}.png',
        iconSize: 0.8.r,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    return Scaffold(
      body: SafeArea(
        top: false,
        right: false,
        left: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MapboxMap(
                    styleString: MapboxStyles.MAPBOX_STREETS,
                    onMapCreated: _onMapCreated,
                    onStyleLoadedCallback: _onStyleLoadedCallBack,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    initialCameraPosition: myCameraPosition,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10.w, top: 40.h),
                        height: 60.h,
                        width: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(13.0.h),
                          child: CircleAvatar(
                            backgroundColor: AppColors.purpleColor,
                            radius: 37.r,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.myActivity.activityPhoto),
                              radius: 34.r,
                              onBackgroundImageError: (exception, stackTrace) =>
                                  AssetImage(
                                      'images/${widget.myActivity.activityCategory.toLowerCase}.png'),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.myActivity.activityTitle,
                            style: Styles.sectionTitleStyle,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0.w, right: 8.0.w),
                          child: GestureDetector(
                            onTap: () {
                              if (company != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CommercialProfileScreen(
                                                user: company!)));
                              }
                            },
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(company!.profilePicture),
                              backgroundColor: AppColors.purpleColor,
                              radius: 25.r,
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: AppColors.purpleColor,
                                      size: 21,
                                    ),
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.lightPurpleColor,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 75.0.h,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  participantCount < 10 ? participantCount : 10,
                              itemBuilder: (BuildContext context, int index) {
                                MiittiUser user = participantList[index];
                                print("$index: ${user.userName} osallistuu");
                                return Padding(
                                  padding: EdgeInsets.only(left: 16.0.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfileEditScreen(
                                                      user: user)));
                                    },
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePicture),
                                      backgroundColor: AppColors.purpleColor,
                                      radius: 25.r,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.myActivity.activityDescription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 15.0.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    /*Expanded(
                      child: SizedBox(),'
                    ),*/
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.myActivity.linkTitle,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 17.0.sp,
                                  color: AppColors.lightPurpleColor,
                                ),
                              ),
                              SizedBox(
                                width: 4.0.w,
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.0.sp,
                                color: Colors.white,
                              )
                            ],
                          ),
                          onTap: () async {
                            await launchUrl(
                                Uri.parse(widget.myActivity.hyperlink));
                          }),
                    ),
                    SizedBox(
                      width: 8.0.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          color: AppColors.lightPurpleColor,
                        ),
                        Text(
                          '  $participantCount/${widget.myActivity.personLimit} osallistujaa',
                          style: Styles.sectionSubtitleStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.lightPurpleColor,
                        ),
                        Text(
                          widget.myActivity.activityAdress,
                          style: Styles.sectionSubtitleStyle,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplane_ticket_outlined,
                          color: AppColors.lightPurpleColor,
                        ),
                        Text(
                          widget.myActivity.isMoneyRequired
                              ? 'Pääsymaksu'
                              : 'Maksuton',
                          style: Styles.sectionSubtitleStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Icon(
                          Icons.calendar_month,
                          color: AppColors.lightPurpleColor,
                        ),
                        Text(
                          widget.myActivity.timeString,
                          style: Styles.sectionSubtitleStyle,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            ),
            widget.comingFromAdmin == true
                ? Container()
                : getMyButton(isLoading)
          ],
        ),
      ),
    );
  }

  void checkIfJoined() async {
    if (isAlreadyJoined) return;

    final ap = Provider.of<AuthProvider>(context, listen: false);
    final activityUid = widget.myActivity.activityUid;

    await ap.checkIfUserJoined(activityUid, commercial: true).then((joined) {
      if (joined) {
        setState(() {
          isAlreadyJoined = true;
        });
      }
    });
  }

  void joinActivity() async {
    checkIfJoined();
    if (!isAlreadyJoined) {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      await ap.joinActivity(widget.myActivity.activityUid);
      PushNotifications.sendAcceptedNotification(
          ap.miittiUser, widget.myActivity);
      setState(() {
        isAlreadyJoined = true;
      });
    }
  }

  Widget getMyButton(bool isLoading) {
    String buttonText = getButtonText();

    if (participantCount < widget.myActivity.personLimit) {
      //There is still place left
      return MyElevatedButton(
        height: 50.h,
        onPressed: () {
          if (!isAlreadyJoined) {
            joinActivity();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComChatPage(activity: widget.myActivity),
              ),
            );
          }
        },
        child: isLoading
            ? LoadingAnimationWidget.waveDots(
                color: Colors.white,
                size: 50.r,
              )
            : Text(
                buttonText,
                style: TextStyle(
                  fontSize: 19.sp,
                  color: Colors.white,
                  fontFamily: 'Rubik',
                ),
              ),
      );
    } else {
      //Its full
      return MyElevatedButton(
        height: 50.h,
        onPressed: () {
          if (isAlreadyJoined) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComChatPage(
                  activity: widget.myActivity,
                ),
              ),
            );
          }
        },
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 19.sp,
            color: Colors.white,
            fontFamily: 'Rubik',
          ),
        ),
      );
    }
  }

  void fetchUsersJoinedActivity() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap
        .fetchUsersByActivityId(widget.myActivity.activityUid)
        .then((value) => setState(() {
              participantList = value;
              participantCount = value.length;
            }));
  }

  void fetchAdmin() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.getCommercialUser(widget.myActivity.admin).then((value) => setState(() {
          company = value;
        }));
  }

  String getButtonText() {
    return isAlreadyJoined
        ? 'Siirry infokanavalle'
        : (participantCount < widget.myActivity.personLimit)
            ? 'Osallistun'
            : 'Täynnä';
  }
}
