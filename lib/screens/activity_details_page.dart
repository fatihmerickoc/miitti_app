import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:miitti_app/screens/chat_page.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/data/person_activity.dart';
import 'package:miitti_app/data/activity.dart';
import 'package:miitti_app/widgets/anonymous_dialog.dart';
import 'package:miitti_app/widgets/confirmdialog.dart';
import 'package:miitti_app/screens/navBarScreens/profile_screen.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:miitti_app/screens/user_profile_edit_screen.dart';
import 'package:miitti_app/utils/utils.dart';

import 'package:miitti_app/widgets/my_elevated_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/miitti_user.dart';

//TODO: New UI

class ActivityDetailsPage extends StatefulWidget {
  const ActivityDetailsPage({
    required this.myActivity,
    super.key,
  });

  final PersonActivity myActivity;

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  late LatLng myCameraPosition;

  UserStatusInActivity userStatus = UserStatusInActivity.none;

  late Future<List<MiittiUser>> filteredUsers;

  int participantCount = 0;
  bool isAnonymous = false;

  @override
  void initState() {
    super.initState();
    userStatus = getStatusInActivity();
    filteredUsers = fetchUsersJoinedActivity();
    filteredUsers.then((users) {
      setState(() {
        participantCount = users.length;
      });
    });

    myCameraPosition = LatLng(
      widget.myActivity.activityLati,
      widget.myActivity.activityLong,
    );
  }

  /*_onMapCreated(MapboxMapController controller) {
    myController = controller;
  }*/

  /*_onStyleLoadedCallBack() {
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
  }*/

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
                  FutureBuilder(
                      future: getPath(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        return FlutterMap(
                            options: MapOptions(
                                keepAlive: true,
                                backgroundColor: AppColors.backgroundColor,
                                initialCenter: myCameraPosition,
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.pinchZoom),
                                minZoom: 5.0,
                                maxZoom: 18.0,
                                onMapReady: () {}),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://api.mapbox.com/styles/v1/miittiapp/clt1ytv8s00jz01qzfiwve3qm/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                                additionalOptions: const {
                                  'accessToken': mapboxAccess,
                                },
                                tileProvider: CachedTileProvider(
                                    store: HiveCacheStore(
                                  snapshot.data.toString(),
                                )),
                              ),
                            ]);
                      }),
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
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
                                      if (isAnonymous) {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const AnonymousDialog());
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ap.miittiUser.uid ==
                                                            user.uid
                                                        ? const ProfileScreen()
                                                        : UserProfileEditScreen(
                                                            user: user)));
                                      }
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
                          return const CircularProgressIndicator(
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
                    const Expanded(
                      child: SizedBox(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
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
                        const Icon(
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
                        const Icon(
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
                        const Icon(
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
            getMyButton(isLoading),
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
                return const ConfirmDialog(
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
    if (userStatus != UserStatusInActivity.none) return;
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.joinOrRequestActivity(widget.myActivity.activityUid).then((newStatus) {
      if (newStatus == UserStatusInActivity.requested) {
        PushNotifications.sendRequestNotification(ap, widget.myActivity);
        setState(() {
          userStatus = UserStatusInActivity.requested;
          widget.myActivity.requests.add(ap.uid);
        });
      } else if (newStatus == UserStatusInActivity.joined) {
        setState(() {
          userStatus = UserStatusInActivity.joined;
          widget.myActivity.participants.add(ap.uid);
        });
      }
    });
  }

  /*void joinIfInvited() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    bool operationCompleted =
        await ap.reactToInvite(widget.myActivity.activityUid, true);
    if (operationCompleted) {
      setState(() {
        userStatus = UserStatusInActivity.joined;
        widget.myActivity.participants.add(ap.uid);
        didGotInvited = false;
      });
    }
  }*/

  Widget getMyButton(bool isLoading) {
    String buttonText = getButtonText();

    return MyElevatedButton(
      height: 50.h,
      onPressed: () {
        if (userStatus == UserStatusInActivity.none &&
            participantCount < widget.myActivity.personLimit) {
          if (isAnonymous) {
            showDialog(
                context: context,
                builder: (context) => const AnonymousDialog());
          } else {
            sendActivityRequest();
          }
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
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: false);
    if (ap.isAnonymous) {
      isAnonymous = true;
      return UserStatusInActivity.none;
    }
    final userId = ap.uid;
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

  Future<String> getPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    return cacheDirectory.path;
  }
}

enum UserStatusInActivity {
  none,
  requested,
  joined,
}
