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
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/push_notifications.dart';
import 'package:miitti_app/userProfileEditScreen.dart';
import 'package:miitti_app/utils/utils.dart';

import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/miittiUser.dart';

class ComActDetailsPage extends StatefulWidget {
  final bool didGotInvited;
  final bool? comingFromAdmin;

  ComActDetailsPage({
    required this.myActivity,
    this.comingFromAdmin,
    this.didGotInvited = false,
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

  late Future<List<MiittiUser>> filteredUsers;
  late CommercialUser company;
  int participantCount = 0;

  @override
  void initState() async {
    super.initState();
    checkIfJoined();
    company = await Provider.of<AuthProvider>(context, listen: false)
        .getCommercialUser(widget.myActivity.admin);
    filteredUsers = fetchUsersJoinedActivity();
    fetchUsersJoinedActivity().then((users) {
      setState(() {
        participantCount = users.length;
      });
    });
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
                        Image.asset(
                          'images/${widget.myActivity.activityCategory.toLowerCase()}.png',
                          height: 100.h,
                          errorBuilder: (cpntext, error, stacktrace) =>
                              Image.asset('images/circlebackground.png'),
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommercialProfileScreen(
                                              user: company)));
                            },
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(company.profilePicture),
                              backgroundColor: AppColors.purpleColor,
                              radius: 25.r,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.verified,
                                  color: AppColors.purpleColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: filteredUsers,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<MiittiUser>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              participantCount = snapshot.data!.length;
                              return SizedBox(
                                height: 75.0.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    MiittiUser user = snapshot.data![index];
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
                                          backgroundColor:
                                              AppColors.purpleColor,
                                          radius: 25.r,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return CircularProgressIndicator(
                                color: AppColors.purpleColor,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: Text(
                        widget.myActivity.activityDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 17.0.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: InkWell(
                          child: Row(
                            children: [
                              Text(
                                widget.myActivity.linkTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 17.0.sp,
                                  color: AppColors.lightPurpleColor,
                                ),
                              ),
                              SizedBox(
                                width: 8.0.w,
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 17.0.sp,
                              )
                            ],
                          ),
                          onTap: () async {
                            await launchUrl(
                                Uri.parse(widget.myActivity.hyperlink));
                          }),
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
                              : 'Ei pääsymaksua',
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
    if (widget.didGotInvited == true) {
      return Opacity(
        opacity: 0.5,
        child: MyElevatedButton(
          height: 50.h,
          onPressed: () {},
          child: Text(
            'Osallistun',
            style: TextStyle(
              fontSize: 19.sp,
              color: Colors.white,
              fontFamily: 'Rubik',
            ),
          ),
        ),
      );
    }

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

  Future<List<MiittiUser>> fetchUsersJoinedActivity() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return await ap.fetchUsersByActivityId(widget.myActivity.activityUid);
  }

  String getButtonText() {
    if (participantCount < widget.myActivity.personLimit) {
      if (isAlreadyJoined) {
        return 'Siirry infokanavalle';
      }
      return 'Osallistun';
    } else {
      if (isAlreadyJoined) {
        return 'Siirry infokanavalle';
      }
      return 'Täynnä';
    }
  }
}
