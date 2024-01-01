// ignore_for_file: prefer_const_constructors

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/notification_message.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/push_notifications.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  //Making sure that 3rd party widgets work properly
  WidgetsFlutterBinding.ensureInitialized();

  //Sets up Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //listen to background
  FirebaseMessaging.onBackgroundMessage(
      PushNotifications.firebaseBackgroundMessage);

  //listen to foreground
  PushNotifications.listenForeground();

  //Listen terminated
  PushNotifications.listenTerminated();

  //Forces the app to only work in Portarait Mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    //Running the app
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: Builder(
          builder: (context) {
            final ap = Provider.of<AuthProvider>(context, listen: false);
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => MaterialApp(
                navigatorKey: navigatorKey,
                theme: ThemeData(
                  scaffoldBackgroundColor: AppColors.backgroundColor,
                ),
                debugShowCheckedModeBanner: false,
                home: _buildAuthScreen(ap),
                routes: {
                  '/notificationmessage': (context) =>
                      const NotificationMessage()
                },
              ),
            );
          },
        ));
  }

  Widget _buildAuthScreen(AuthProvider ap) {
    //Just checking if the user is signed up, before opening our app.
    return FutureBuilder<bool>(
      future: ap.checkSign(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        //If the user is signed in to our app  before, we redirect them into our main screen, otherwise they go to home screen to register or sign up
        if (ap.isSignedIn) {
          ap.getDataFromSp();
          return IndexPage();
        } else {
          return HomePage();
        }
      },
    );
  }
}
