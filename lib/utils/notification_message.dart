import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:miitti_app/chatPage.dart';
import 'package:miitti_app/commercialScreens/comchat_page.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/createMiittiActivity/activity_details_page.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/userProfileEditScreen.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:miitti_app/provider/auth_provider.dart';

class NotificationMessage extends StatefulWidget {
  const NotificationMessage({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    Map<String, dynamic> payload = {};

    if (data is RemoteMessage) {
      payload = data.data;
      print("RemoteMessage opened");
    }

    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
      print("Notification response opened");
    }

    //Navigate insted of creating here
    getPage(payload, context).then((page) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => page));
    });

    return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ));
  }
}

Future<Widget> getPage(
    Map<String, dynamic> payload, BuildContext context) async {
  //Open activity page
  try {
    if (payload.containsKey("type")) {
      AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
      switch (payload["type"]) {
        case ("invite"):
          print("Invite clicked ${payload["myData"]}");
          PersonActivity activity = await provider
              .getSingleActivity(payload["myData"]) as PersonActivity;
          return ActivityDetailsPage(myActivity: activity);

        case ("request"):
          print("Request clicked ${payload["myData"]}");
          MiittiUser user = await provider.getUser(payload["myData"]);
          return UserProfileEditScreen(user: user);

        case ("accept"):
          print("Accept clicked ${payload["myData"]}");
          PersonActivity activity = await provider
              .getSingleActivity(payload["myData"]) as PersonActivity;
          return ActivityDetailsPage(myActivity: activity);

        case ("message"):
          print("Message clicked ${payload["myData"]}");
          MiittiActivity activity =
              await provider.getSingleActivity(payload["myData"]);
          if (activity is PersonActivity) {
            return ChatPage(activity: activity);
          } else {
            return ComChatPage(activity: activity as CommercialActivity);
          }
      }
      print("Type didn't match: ${payload["type"].toString()}");
    } else {
      print("Payload doesn't include that type");
    }

    return const IndexPage();
  } catch (e) {
    print("Error: $e");
    return const IndexPage();
  }
}
