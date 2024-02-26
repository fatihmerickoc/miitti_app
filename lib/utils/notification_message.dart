import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:miitti_app/chatPage.dart';
import 'package:miitti_app/commercialScreens/comchat_page.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
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

    return getPage(payload, context);
  }
}

Widget getPage(Map<String, dynamic> payload, BuildContext context) {
  //Open activity page
  if (payload.containsKey("type")) {
    switch (payload["type"]) {
      case ("invite"):
        print("Invite clicked ${payload["myData"]}");
        return FutureBuilder<MiittiActivity>(
            future: Provider.of<AuthProvider>(context, listen: false)
                .getSingleActivity(payload["myData"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ActivityDetailsPage(
                    myActivity: snapshot.data! as PersonActivity);
              } else if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return const IndexPage();
              } else {
                return const IndexPage();
              }
            });
      case ("request"):
        print("Request clicked ${payload["myData"]}");
        return FutureBuilder<MiittiUser>(
            future: Provider.of<AuthProvider>(context, listen: false)
                .getUser(payload["myData"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return UserProfileEditScreen(user: snapshot.data!);
              } else if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return const IndexPage();
              } else {
                return const CircularProgressIndicator();
              }
            });
      case ("accept"):
        print("Invite clicked ${payload["myData"]}");
        return FutureBuilder<Widget>(
            future: Provider.of<AuthProvider>(context, listen: false)
                .getDetailsPage(payload["myData"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data!;
              } else if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return const IndexPage();
              } else {
                return const CircularProgressIndicator();
              }
            });
      case ("message"):
        print("Message clicked ${payload["myData"]}");
        return FutureBuilder<MiittiActivity>(
            future: Provider.of<AuthProvider>(context, listen: false)
                .getSingleActivity(payload["myData"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                MiittiActivity a = snapshot.data!;
                if (a is PersonActivity) {
                  return ChatPage(activity: a);
                } else {
                  return ComChatPage(activity: a as CommercialActivity);
                }
              } else if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return const IndexPage();
              } else {
                return const CircularProgressIndicator();
              }
            });
    }
    print("Type didn't match: ${payload["type"].toString()}");
  } else {
    print("Payload doesn't include type");
  }

  return const IndexPage();
}
