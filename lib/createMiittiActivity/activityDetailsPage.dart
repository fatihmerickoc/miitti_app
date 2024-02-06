// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:miitti_app/chatPage.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/helpers/confirmdialog.dart';
import 'package:miitti_app/navBarScreens/profileScreen.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:miitti_app/userProfileEditScreen.dart';
import 'package:miitti_app/utils/utils.dart';

import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

import '../constants/miittiUser.dart';

class ActivityDetailsPage extends StatefulWidget {
  bool didGotInvited;
  final bool? comingFromAdmin;

  ActivityDetailsPage({
    required this.myActivity,
    this.comingFromAdmin,
    this.didGotInvited = false,
    super.key,
  });

  PersonActivity myActivity;

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  late CameraPosition myCameraPosition;
  late MapboxMapController myController;

  UserStatusInActivity userStatus = UserStatusInActivity.none;

  late Future<List<MiittiUser>> filteredUsers;

  int participantCount = 0;

  @override
  void initState() {
    super.initState();
    userStatus = getStatusInActivity();
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
            'images/${Activity.solveActivityId(widget.myActivity.activityCategory)}.png',
        iconSize: 0.8.r,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: true);
    final isLoading = ap.isLoading;

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
                          'images/${Activity.solveActivityId(widget.myActivity.activityCategory)}.png',
                          height: 90.h,
                        ),
                        Flexible(
                          child: Text(
                            widget.myActivity.activityTitle,
                            style: Styles.sectionTitleStyle,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder(
                      future: filteredUsers,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<MiittiUser>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          participantCount = snapshot.data!.length;
                          return SizedBox(
                            height: 75.0.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                MiittiUser user = snapshot.data![index];
                                return Padding(
                                  padding: EdgeInsets.only(left: 16.0.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ap.miittiUser.uid == user.uid
                                                      ? ProfileScreen()
                                                      : UserProfileEditScreen(
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
                          );
                        } else {
                          return CircularProgressIndicator(
                            color: AppColors.purpleColor,
                          );
                        }
                      },
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
                : getMyButton(isLoading),
            reportActivity(ap)
          ],
        ),
      ),
    );
  }

  Widget reportActivity(AuthProvider ap) {
    if (userStatus == UserStatusInActivity.joined) {
      return Center(
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmDialog(
                  title: 'Varmistus',
                  leftButtonText: 'Ilmianna',
                  mainText: 'Oletko varma, että haluat ilmiantaa aktiviteetin?',
                );
              },
            ).then(
              (confirmed) {
                if (confirmed) {
                  ap.reportActivity('Activity blocked',
                      widget.myActivity.activityUid, ap.uid);

                  Navigator.of(context).pop();
                  showSnackBar(context, "Aktiviteetti ilmiannettu",
                      Colors.green.shade800);
                }
              },
            );
          },
          child: Container(
            margin: EdgeInsets.only(top: 10.h),
            child: Text(
              "Ilmianna aktiviteetti",
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 19.sp,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  void sendActivityRequest() async {
    if (userStatus == UserStatusInActivity.none) {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      await ap.sendActivityRequest(widget.myActivity.activityUid);
      PushNotifications.sendRequestNotification(ap, widget.myActivity);
      setState(() {
        userStatus = UserStatusInActivity.requested;
        widget.myActivity.requests.add(ap.uid);
      });
    }
  }

  void joinIfInvited() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    bool operationCompleted =
        await ap.reactToInvite(widget.myActivity.activityUid, true);
    if (operationCompleted) {
      setState(() {
        userStatus = UserStatusInActivity.joined;
        widget.myActivity.participants.add(ap.uid);
        widget.didGotInvited = false;
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

    return MyElevatedButton(
      height: 50.h,
      onPressed: () {
        if (userStatus == UserStatusInActivity.none &&
            participantCount < widget.myActivity.personLimit) {
          sendActivityRequest();
        } else if (userStatus == UserStatusInActivity.joined) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(activity: widget.myActivity),
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
  }

  Future<List<MiittiUser>> fetchUsersJoinedActivity() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return ap.fetchUsersByUids(widget.myActivity.participants);
  }

  UserStatusInActivity getStatusInActivity() {
    final userId = Provider.of<AuthProvider>(context, listen: false).uid;
    return widget.myActivity.participants.contains(userId)
        ? UserStatusInActivity.joined
        : widget.myActivity.requests.contains(userId)
            ? UserStatusInActivity.requested
            : UserStatusInActivity.none;
  }

  String getButtonText() {
    if (userStatus == UserStatusInActivity.requested) {
      return 'Odottaa hyväksyntää';
    } else if (userStatus == UserStatusInActivity.joined) {
      return 'Siirry keskusteluun';
    } else {
      return participantCount < widget.myActivity.personLimit
          ? 'Osallistun'
          : 'Täynnä';
    }
  }
}

enum UserStatusInActivity {
  none,
  requested,
  joined,
}
