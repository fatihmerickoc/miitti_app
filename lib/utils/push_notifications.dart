import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/main.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init(AuthProvider ap) async {
    //on background notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Background notification tapped");
        navigatorKey.currentState!
            .pushNamed("/notificationmessage", arguments: message);
      }
    });

    //Request notification permission
    await _firebaseMessaging.requestPermission();

    if (Platform.isIOS) {
      final apnstToken = await _firebaseMessaging.getAPNSToken();
      await Future.delayed(const Duration(seconds: 1));
    }

    //get the device FCM(Firebase Cloud Messaging) token
    final token = await _firebaseMessaging.getToken();
    print("###### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFCIATION ######");
    print(token);
    print("############################################################");

    //Save token to user data(needed to access other users tokens in code)
    if (ap.miittiUser.fcmToken != token) {
      ap.miittiUser.fcmToken = token!;
      ap.updateUserInfo(updatedUser: ap.miittiUser);
    }
  }

  static Future firebaseBackgroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      String? title = message.notification?.title;
      print("Notification received $title");
    }
  }

  // initalize local notifications
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
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
      print("Got a message in foreground");
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
      print("Launched from terminated state");
      Future.delayed(const Duration(seconds: 1), () {
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
    MiittiUser admin = await ap.getUser(activity.admin);
    sendNotification(
      admin.fcmToken,
      "Pääsiskö miittiin mukaan?",
      "${ap.miittiUser.userName} pyysi päästä miittiin: ${activity.activityTitle}",
      "request",
      ap.miittiUser.uid,
    );
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
    print("Trying to send message: $message");
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
      print("Result sending notification: ${response.data}");
    } on FirebaseFunctionsException catch (e, s) {
      print("Error calling ${callable.toString()}: $e");
      print("$s");
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
