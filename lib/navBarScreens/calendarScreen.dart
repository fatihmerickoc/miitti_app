// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/chatPage.dart';
import 'package:miitti_app/commercialScreens/comact_detailspage.dart';
import 'package:miitti_app/commercialScreens/comchat_page.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/createMiittiActivity/activityDetailsPage.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/helpers/confirmdialog.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:miitti_app/userProfileEditScreen.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  //List of Activities that user has been joined or sended a request to join
  List<MiittiActivity> _myJoinedActivities = [];

  //List of Users that requested to join our activity
  List<Map<String, dynamic>> _otherRequests = [];

  // Boolean that is used for toggleSwitch to decide whether to show _myJoinedActivities or _otherRequests
  bool showMyActivities = true;

  //Boolean that is used to show a CircularProgressIndicator in the center if data is still fetching from database
  bool isLoading = true;

  late BuildContext myContext;

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Fetching all the data from database
    fetchDataFromFirebase();
  }

  Future fetchDataFromFirebase() async {
    //This method ensures that all the data is coming successfully from Database through AuthProvider and then updates the State
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final joinedActivities = await ap.fetchUserActivities();
    final comingRequests = await ap.fetchActivitiesRequests();

    _myJoinedActivities = joinedActivities;
    _otherRequests = comingRequests;
    isLoading = false;
    setState(() {});
  }

  Color getColorForContainer(bool isAdmin, bool isInvited) {
    if (isAdmin) {
      return AppColors.pinkColor;
    } else if (isInvited) {
      return AppColors.yellowColor;
    } else {
      return AppColors.purpleColor;
    }
  }

  Widget buildActivityItem(
    MiittiActivity activity,
    bool isAdmin,
    bool isWaiting,
    int index,
    bool isInvited,
  ) {
    //initializing the AuthProvider
    final ap = Provider.of<AuthProvider>(context);

    String activityAddress = activity.activityAdress;

    List<String> addressParts = activityAddress.split(',');
    String cityName = addressParts[0].trim();

    return Container(
      height: 150.h,
      margin: EdgeInsets.all(10.0.w),
      decoration: BoxDecoration(
        color: AppColors.wineColor,
        border: Border.all(
          color: getColorForContainer(isAdmin, isInvited),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              //When the MiittiActivityImage is clicked, user is pushed to the Activity Details Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => activity is PersonActivity
                      ? ActivityDetailsPage(
                          myActivity: activity,
                          didGotInvited: isInvited,
                        )
                      : ComActDetailsPage(
                          myActivity: activity as CommercialActivity),
                ),
              );
            },
            child: Activity.getSymbol(activity),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Activity Title
                      Flexible(
                        child: Text(
                          activity.activityTitle,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.activityNameTextStyle,
                        ),
                      ),
                      //If the activity is created by the admin, we show deleteforever icon instead of close icon for user friendliness.
                      isAdmin
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDialog(
                                      title: 'Varmistus',
                                      mainText:
                                          'Oletko varma, että haluat poistaa?',
                                    );
                                  },
                                ).then((confirmed) {
                                  if (confirmed != null && confirmed) {
                                    ap.removeActivity(activity.activityUid);
                                    setState(() {
                                      fetchDataFromFirebase();
                                    });
                                  } else {
                                    // User canceled the deletion
                                  }
                                });
                              },
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDialog(
                                      title: 'Varmistus',
                                      mainText: isWaiting
                                          ? 'Haluatko varmasti peruuttaa liittymispyyntösi?'
                                          : 'Oletko varma, että haluat poistua miitistä?',
                                    );
                                  },
                                ).then((confirmed) {
                                  if (confirmed != null && confirmed) {
                                    ap.removeUserFromActivity(
                                      activity.activityUid,
                                      isWaiting,
                                    );
                                    setState(() {
                                      fetchDataFromFirebase();
                                    });
                                  } else {
                                    // User canceled the deletion
                                  }
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                    ],
                  ),
                  //Normally, we show activity's location and time, but if user is invited to another activity, we show them a text sayin that they are invited
                  isInvited
                      ? Flexible(
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Sinulle on aktiviteettikutsu',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                                fontFamily: 'Sora',
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.lightPurpleColor,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                activity.timeString,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.sectionSubtitleStyle,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.lightPurpleColor,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                cityName,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.sectionSubtitleStyle,
                              ),
                            ),
                          ],
                        ),

                  //Normally, we show a button that will lead to activity's chat page but if user is invited to another activity, we show them 2 buttons to accept the invitation or decline it
                  isInvited
                      ? Row(
                          children: [
                            Expanded(
                              child: MyElevatedButton(
                                height: 40.h,
                                onPressed: () async {
                                  bool operationCompleted =
                                      await ap.reactToInvite(
                                          activity.activityUid, false);
                                  if (!operationCompleted) {
                                    _myJoinedActivities.removeAt(index);
                                    fetchDataFromFirebase().then(
                                      (value) {
                                        buildJoinedActivities();
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  "Hylkää",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              child: MyElevatedButton(
                                height: 40.h,
                                onPressed: () async {
                                  bool operationCompleted =
                                      await ap.reactToInvite(
                                          activity.activityUid, true);
                                  if (operationCompleted) {
                                    fetchDataFromFirebase().then(
                                        (value) => buildJoinedActivities());
                                  }
                                },
                                child: Text(
                                  "Hyväksy",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: Opacity(
                            opacity: isWaiting ? 0.8 : 1,
                            child: MyElevatedButton(
                              width: 250.w,
                              height: 40.w,
                              onPressed: () {
                                if (!isWaiting) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          activity is PersonActivity
                                              ? ChatPage(
                                                  activity: activity,
                                                )
                                              : ComChatPage(
                                                  activity: activity
                                                      as CommercialActivity),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                isWaiting
                                    ? 'Odottaa hyväksyntää'
                                    : "Siirry keskusteluun",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserItem(Map<String, dynamic> userData, int index) {
    final ap = Provider.of<AuthProvider>(context);
    final MiittiUser user = userData['user'];
    final PersonActivity activity = userData['activity'];
    return Container(
      height: 150.h,
      margin: EdgeInsets.all(10.0.w),
      decoration: BoxDecoration(
        color: AppColors.wineColor,
        border: Border.all(color: AppColors.purpleColor, width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfileEditScreen(user: user)));
            },
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: ClipOval(
                child: Image.network(
                  user.profilePicture,
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActivityDetailsPage(
                                      myActivity: activity,
                                    )));
                      },
                      child: Text(
                        activity.activityTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubik',
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${user.userName} haluaa liittyä aktiviteettiin',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 16.sp,
                            color: AppColors.whiteColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyElevatedButton(
                          height: 40.h,
                          onPressed: () async {
                            bool operationCompleted =
                                await ap.updateUserJoiningActivity(
                                    activity.activityUid, user.uid, false);
                            if (!operationCompleted) {
                              _otherRequests.removeAt(index);
                              fetchDataFromFirebase().then((value) {
                                buildOtherActivities();
                              });
                            }
                          },
                          child: Text(
                            "Hylkää",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: MyElevatedButton(
                          height: 40.h,
                          onPressed: () async {
                            bool operationCompleted =
                                await ap.updateUserJoiningActivity(
                                    activity.activityUid, user.uid, true);
                            if (operationCompleted) {
                              fetchDataFromFirebase()
                                  .then((value) => buildOtherActivities());
                            } else {
                              PushNotifications.sendAcceptedNotification(
                                  user, activity);
                            }
                          },
                          child: Text(
                            "Hyväksy",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainToggleSwitch() {
    //Creates a toggle switch that controls whether to show myActivities or otherRequests
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createMainToggleSwitch(
          text1: 'Omat pyynnöt',
          text2: _otherRequests.isEmpty
              ? 'Muiden pyynnöt'
              : 'Muiden pyynnöt (${_otherRequests.length})',
          initialLabelIndex: showMyActivities ? 0 : 1,
          onToggle: (index) {
            //Updates the state when ToggleSwitch is toggled
            setState(() {
              showMyActivities = !showMyActivities;
            });
          },
        ),
      ],
    );
  }

  Widget buildOtherActivities() {
    return _otherRequests.isNotEmpty
        ? ListView.builder(
            itemCount: _otherRequests.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> userData = _otherRequests[index];
              return buildUserItem(userData, index);
            },
          )
        : Center(
            child: Text(
              'Kukaan ei ole vielä lähettänyt liittymispyyntöä',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontFamily: 'Sora',
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }

  Widget buildJoinedActivities() {
    //This method returns a list of activities based on if the _myJoinedActivities is null or not
    return _myJoinedActivities.isNotEmpty
        ? ListView.builder(
            itemCount: _myJoinedActivities.length,
            itemBuilder: (BuildContext context, int index) {
              //getting the single activity from the list
              MiittiActivity singleActivity = _myJoinedActivities[index];

              final ap = Provider.of<AuthProvider>(context);
              String userId = ap.uid;

              //checking if the activity is created by the user
              bool isAdmin = singleActivity.admin == userId;

              //checking if the user is in the activity's request list
              bool isWaiting = singleActivity is PersonActivity
                  ? singleActivity.requests.contains(userId)
                  : false;

              //checking if the user has been invited into other activities
              bool isInvited = singleActivity is PersonActivity
                  ? !singleActivity.requests.contains(userId) &&
                      !singleActivity.participants.contains(userId)
                  : false;

              return buildActivityItem(
                  singleActivity, isAdmin, isWaiting, index, isInvited);
            },
          )
        : //Returning a info text to the user if the data is null
        Center(
            child: Text(
              'Et ole osallistunut mihinkään aktiviteettiin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontFamily: 'Sora',
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lavenderColor,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 60.h),
                  child: showMyActivities
                      ? buildJoinedActivities()
                      : buildOtherActivities(),
                ),
          //ToggleSwitch that is right at the top of screen
          buildMainToggleSwitch(),
        ],
      ),
    );
  }
}
