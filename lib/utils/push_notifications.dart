import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:miitti_app/data/miitti_activity.dart';
import 'package:miitti_app/data/person_activity.dart';
import 'package:miitti_app/data/miitti_user.dart';
import 'package:miitti_app/main.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<bool> checkPermission() async {
    return await Permission.notification.isGranted;
  }

  static Future<bool> requestPermission(bool requestEvenDenied) async {
    bool permanentlyDenied = await Permission.notification.isPermanentlyDenied;
    if (permanentlyDenied && requestEvenDenied) {
      await openAppSettings();
      return await Permission.notification.isGranted;
    } else {
      return await Permission.notification.request().isGranted;
    }
  }

  static Future init(AuthProvider ap) async {
    //on background notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint("Background notification tapped");
        navigatorKey.currentState!
            .pushNamed("/notificationmessage", arguments: message);
      }
    });

    //Request notification permission
    await _firebaseMessaging.requestPermission();

    if (Platform.isIOS) {
      await _firebaseMessaging.getAPNSToken();
      await Future.delayed(const Duration(seconds: 1));
    }

    //get the device FCM(Firebase Cloud Messaging) token
    final token = await _firebaseMessaging.getToken();
    debugPrint("###### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFCIATION ######");
    debugPrint(token);
    debugPrint("############################################################");

    //Save token to user data(needed to access other users tokens in code)
    if (!ap.isAnonymous) {
      if (ap.miittiUser.fcmToken != token) {
        ap.miittiUser.fcmToken = token!;
        ap.updateUserInfo(updatedUser: ap.miittiUser);
      }
    }
  }

  static Future firebaseBackgroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      String? title = message.notification?.title;
      debugPrint("Notification received $title");
    }
  }

  // initalize local notifications
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  static void listenForeground() {
    // to handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String payloadData = jsonEncode(message.data);
      debugPrint("Got a message in foreground");
      if (message.notification != null) {
        PushNotifications.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    });
  }

  static void listenTerminated() async {
    // for handling in terminated state
    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      debugPrint("Launched from terminated state");
      Future.delayed(const Duration(seconds: 2), () {
        navigatorKey.currentState!
            .pushNamed("/notificationmessage", arguments: message);
      });
    }
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    notificationResponse.payload;
    navigatorKey.currentState!
        .pushNamed("/notificationmessage", arguments: notificationResponse);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  static void sendInviteNotification(
      MiittiUser current, MiittiUser receiver, PersonActivity activity) async {
    sendNotification(
      receiver.fcmToken,
      "Sait kutsun miittiin!",
      "${current.userName} haluis sut mukaan miittiin: ${activity.activityTitle}",
      "invite",
      activity.activityUid,
    );
  }

  static Future sendRequestNotification(
      AuthProvider ap, PersonActivity activity) async {
    MiittiUser? admin = await ap.getUser(activity.admin);
    if (admin != null) {
      sendNotification(
        admin.fcmToken,
        "Pääsiskö miittiin mukaan?",
        "${ap.miittiUser.userName} pyysi päästä miittiin: ${activity.activityTitle}",
        "request",
        ap.miittiUser.uid,
      );
    } else {
      debugPrint("Couldn't find admin to send request notification to.");
    }
  }

  static void sendAcceptedNotification(
      MiittiUser receiver, MiittiActivity activity) async {
    sendNotification(
      receiver.fcmToken,
      "Tervetuloa miittiin!",
      "Sut hyväksyttiin miittiin: ${activity.activityTitle}",
      "accept",
      activity.activityUid,
    );
  }

  static Future sendNotification(String receiverToken, String title,
      String message, String type, String data) async {
    debugPrint("Trying to send message: $message");
    final callable =
        FirebaseFunctions.instance.httpsCallable("sendNotificationTo");
    try {
      final response = await callable.call({
        "receiver": receiverToken,
        "title": title,
        "message": message,
        "type": type,
        "myData": data,
      });
      debugPrint("Result sending notification: ${response.data}");
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint("Error calling ${callable.toString()}: $e");
      debugPrint("$s");
    }
  }

  static void sendMessageNotification(String receiverToken, String senderName,
      MiittiActivity activity, String message) async {
    sendNotification(
      receiverToken,
      "Uusi viesti miitissä ${activity.activityTitle}",
      "$senderName: $message",
      "message",
      activity.activityUid,
    );
  }
}
