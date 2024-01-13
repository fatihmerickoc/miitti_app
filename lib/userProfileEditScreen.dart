// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/helpers/confirmdialog.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/push_notifications.dart';

import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

class UserProfileEditScreen extends StatefulWidget {
  final MiittiUser user;
  final bool? comingFromAdmin;
  const UserProfileEditScreen(
      {required this.user, this.comingFromAdmin, super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  Color miittiColor = Color.fromRGBO(255, 136, 27, 1);

  List<Activity> filteredActivities = [];

  String userReportReason = "";

  @override
  void initState() {
    super.initState();
    //Initialize the list from given data
    filteredActivities = activities
        .where((activity) =>
            widget.user.userFavoriteActivities.contains(activity.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: true);
    final isLoading = ap.isLoading;

    List<String> answeredQuestions = questionOrder
        .where((question) => widget.user.userChoices.containsKey(question))
        .toList();

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
                    widget.user.userName,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  buildUserStatus(),
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
            height: 210.w,
            child: PageView.builder(
                itemCount: widget.user.userChoices.length,
                itemBuilder: (context, index) {
                  String question = answeredQuestions[index];
                  String answer = widget.user.userChoices[question]!;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(10.w),
                    child: Container(
                      margin: EdgeInsets.only(left: 20.w, top: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.purpleColor,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 22.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            answer,
                            maxLines: 4,
                            style: TextStyle(
                              color: Colors.black,
                              wordSpacing: 2.0,
                              fontSize: 25.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            child: Container(
              height: 320.w,
              margin: EdgeInsets.only(
                left: 5.w,
                top: 10.h,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      widget.user.userArea,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      widget.user.userGender,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cake,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      calculateAge(widget.user.userBirthday).toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.g_translate,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      widget.user.userLanguages.join(', '),
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.next_week,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      'Opiskelija',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          SizedBox(
            height: filteredActivities.length > 3 ? 250.w : 125.w,
            child: GridView.builder(
              itemCount: filteredActivities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (context, index) {
                final activity = filteredActivities[index];
                return Container(
                  height: 100.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: [
                      Text(
                        activity.emojiData,
                        style: TextStyle(fontSize: 50.0.sp),
                      ),
                      Text(
                        activity.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 19.0.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          widget.comingFromAdmin != null
              ? Container()
              : Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 15.w,
                  ),
                  child: MyElevatedButton(
                    onPressed: () => inviteToYourActivity(),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Kutsu miittiin',
                            style: Styles.bodyTextStyle,
                          ),
                  ),
                ),
          Center(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmDialog(
                      title: 'Vahvistus',
                      leftButtonText: 'Ilmianna',
                      mainText:
                          'Oletko varma, että haluat ilmiantaa käyttäjän?',
                      mainContent: Padding(
                        padding: EdgeInsets.only(top: 8.0.h),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontFamily: 'Rubik',
                          ),
                          onChanged: (text) {
                            userReportReason = text;
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'Ilmiantamisen syy:',
                            counterStyle: TextStyle(
                              color: Colors.white,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: TextStyle(
                              fontSize: 17.sp,
                              color: Colors.white70,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).then((confirmed) {
                  if (confirmed == null) {
                    showSnackBar(
                        context, "Tapahtui virhe!", Colors.red.shade800);
                  } else if (confirmed) {
                    if (userReportReason == "") {
                      showSnackBar(
                          context,
                          "Ilmiantamisen syy ei voi olla tyhjä!",
                          Colors.red.shade800);
                    } else {
                      ap.reportUser(userReportReason, widget.user.uid, ap.uid);

                      Navigator.of(context).pop();
                      showSnackBar(context, "Käyttäjä ilmiannettu",
                          Colors.green.shade800);
                    }
                  }
                });
              },
              child: Text(
                "Ilmianna käyttäjä",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 19.sp,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> inviteToYourActivity() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    List<PersonActivity> myActivities = await ap.fetchAdminActivities();

    if (myActivities.isNotEmpty) {
      if (myActivities.length == 1 &&
          myActivities.first.participants.length <
              myActivities.first.personLimit &&
          !myActivities.first.participants.contains(widget.user.uid) &&
          !myActivities.first.requests.contains(widget.user.uid)) {
        ap
            .inviteUserToYourActivity(
                widget.user.uid, myActivities.first.activityUid)
            .then((value) {
          PushNotifications.sendInviteNotification(
              ap.miittiUser, widget.user, myActivities.first);
          showDialog(
            context: context,
            barrierColor: Colors.white.withOpacity(0.9),
            builder: (BuildContext context) {
              return createInviteActivityDialog();
            },
          );
        });
      } else if (myActivities.length > 1) {
        //If user has 2 or more activites to invite to
        showDialog(
          context: context,
          barrierColor: Colors.white.withOpacity(0.9),
          builder: (BuildContext context) {
            return createSelectBetweenActivitesDialog(myActivities);
          },
        );
      } else {
        // Show some red dialog
        print("You do not have any activities for people to invite");
      }
    }
  }

  Widget buildUserStatus() {
    Color color;
    String status = getUserStatus();

    switch (status) {
      case 'Paikalla':
        color = Colors.green;
        break;
      case 'Paikalla äskettäin':
        color = Colors.lightGreen;
        break;
      case 'Paikalla tänään':
        color = Colors.lightBlue.shade300;
        break;
      case 'Paikalla tällä viikolla':
        color = Colors.orange;
        break;
      case 'Epäaktiivinen':
      default:
        color = Colors.red;
    }
    return Text(
      '● $status',
      style: TextStyle(
        color: color,
        fontSize: 15.0.sp,
        fontFamily: 'Sora',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String getUserStatus() {
    if (widget.user.userStatus.isNotEmpty) {
      String lastActiveString = widget.user.userStatus;
      DateTime lastActiveDate = DateTime.parse(lastActiveString).toLocal();
      Duration difference = DateTime.now().difference(lastActiveDate);

      if (difference < const Duration(minutes: 5)) {
        return 'Paikalla';
      } else if (difference < const Duration(hours: 1)) {
        return 'Paikalla äskettäin';
      } else if (difference < const Duration(hours: 24)) {
        return 'Paikalla tänään';
      } else if (difference < const Duration(days: 7)) {
        return 'Paikalla tällä viikolla';
      } else if (difference > const Duration(days: 7)) {
        return 'Epäaktiivinen';
      } else {
        return 'Paikalla';
      }
    } else {
      return 'Paikalla';
    }
  }

  Widget createSelectBetweenActivitesDialog(List<PersonActivity> myActivities) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: AppColors.wineColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        height: 330.w,
        width: 330.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/thinkingFace.png',
              height: 125.w,
              width: 125.w,
            ),
            Text(
              'Valitse kutsuttava aktiviteetti',
              textAlign: TextAlign.center,
              style: Styles.sectionTitleStyle,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: myActivities.length,
                itemBuilder: (context, index) {
                  PersonActivity activity = myActivities[index];
                  return ListTile(
                    leading: Image.asset(
                      'images/${activity.activityCategory.toLowerCase()}.png',
                    ),
                    subtitle: Text(
                      activity.activityDescription,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    title: Text(
                      activity.activityTitle,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 19.sp,
                        overflow: TextOverflow.ellipsis,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    onTap: () {
                      if (activity.participants.length < activity.personLimit &&
                          !activity.participants.contains(widget.user.uid) &&
                          !activity.requests.contains(widget.user.uid)) {
                        ap
                            .inviteUserToYourActivity(
                                widget.user.uid, activity.activityUid)
                            .then((value) {
                          PushNotifications.sendInviteNotification(
                              ap.miittiUser, widget.user, activity);
                          Navigator.of(context).pop(); // Close the SimpleDialog
                          showDialog(
                            context: context,
                            barrierColor: Colors.white.withOpacity(0.9),
                            builder: (BuildContext context) {
                              return createInviteActivityDialog();
                            },
                          );
                        });
                      } else {
                        Navigator.of(context).pop();
                        // Show a dialog or some other UI element indicating that this activity is full or the user is already a participant/requested to join
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createInviteActivityDialog() {
    return AlertDialog(
      backgroundColor: AppColors.wineColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        height: 300.w,
        width: 300.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/postbox.png',
              height: 125.w,
              width: 125.w,
            ),
            Text(
              'Kutsu miittisi on lähetetty',
              textAlign: TextAlign.center,
              style: Styles.sectionTitleStyle,
            ),
            Text(
              'Kun ${widget.user.userName} on hyväksynyt kutsun liittyvä miittisi, saat siitä push ilmoituksen',
              textAlign: TextAlign.center,
              style: Styles.sectionSubtitleStyle,
            ),
            MyElevatedButton(
              height: 45.h,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 2);
              },
              child: Text(
                'Kutsu muita',
                style: Styles.activityNameTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
