import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/screens/index_page.dart';
import 'package:miitti_app/screens/login/login_intro.dart';
import 'package:miitti_app/utils/notification_message.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:provider/provider.dart';
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
        create: (context) => AuthProvider(context),
        child: Builder(
          builder: (context) {
            final ap = Provider.of<AuthProvider>(context, listen: false);
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => MaterialApp(
                navigatorKey: navigatorKey,
                theme: ThemeData(
                  scaffoldBackgroundColor: AppColors.backgroundColor,
                  fontFamily: 'RedHatDisplay',
                ),
                debugShowCheckedModeBanner: false,
                home: _buildAuthScreen(ap, context),
                routes: {
                  '/notificationmessage': (context) =>
                      const NotificationMessage()
                },
              ),
            );
          },
        ));
  }

  Widget _buildAuthScreen(AuthProvider ap, BuildContext context) {
    //Just checking if the user is signed up, before opening our app.
    return FutureBuilder<bool>(
      future: ap.checkSign(context),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        //If the user is signed in to our app  before, we redirect them into our main screen, otherwise they go to home screen to register or sign up
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            ap.isSignedIn) {
          return const IndexPage();
        } else {
          return const LoginIntro();
        }
      },
    );
  }
}
