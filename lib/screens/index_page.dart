import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miitti_app/widgets/anonymous_dialog.dart';
import 'package:miitti_app/screens/createMiittiActivity/activity_onboarding.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/push_notifications.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

import 'navBarScreens/calendar_screen.dart';
import 'navBarScreens/settings_screen.dart';
import 'navBarScreens/maps_screen.dart';
import 'navBarScreens/people_screen.dart';
import 'navBarScreens/profile_screen.dart';

class IndexPage extends StatefulWidget {
  final int? initialPage;

  const IndexPage({super.key, this.initialPage});

  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> with WidgetsBindingObserver {
  //Integer index that is used for deciding which screen gets to be displayed in body
  int currentIndex = 1;

  // List of screen widgets
  static const List<Widget> _pages = <Widget>[
    CalendarScreen(),
    MapsScreen(),
    PeopleScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    initPushNotifications();

    WidgetsBinding.instance.addObserver(this);

    // Initialize selected index if an initialPage is provided
    if (widget.initialPage != null &&
        widget.initialPage! >= 0 &&
        widget.initialPage! < 5) {
      currentIndex = widget.initialPage!;
    }

    //_pageController = PageController(initialPage: currentIndex);

    // Update user status on initialization
    setUserStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Update user status on lifecycle changes
    if (state == AppLifecycleState.resumed) {
      setUserStatus();
    }
  }

  // Helper function to update the user status

  void setUserStatus() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.setUserStatus();
  }

  void initPushNotifications() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    PushNotifications.init(ap);
    PushNotifications.localNotiInit();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      // Navigation bar at the bottom
      bottomNavigationBar: _buildBottomNavigationBar(),
      // Only display FAB for tab with index 1
      floatingActionButton: currentIndex == 1
          ? SizedBox(
              height: 65.h,
              width: 65.h,
              child: getMyFloatingButton(
                onPressed: () async {
                  if (ap.isAnonymous) {
                    showDialog(
                        context: context,
                        builder: (context) => const AnonymousDialog());
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivityOnboarding(),
                      ),
                    );
                  }
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Display the selected screen
      body: _pages[currentIndex],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      color: AppColors.backgroundColor,
      child: GNav(
        gap: 8,
        color: AppColors.lavenderColor,
        activeColor: AppColors.mixGradientColor,
        selectedIndex: currentIndex,
        onTabChange: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        padding: EdgeInsets.all(16.w),
        tabs: [
          GButton(icon: Icons.calendar_month, iconSize: 35.sp),
          GButton(icon: Icons.location_on, iconSize: 35.sp),
          GButton(icon: Icons.people, iconSize: 35.sp),
          GButton(icon: Icons.person, iconSize: 35.sp),
          GButton(icon: Icons.settings, iconSize: 35.sp),
        ],
      ),
    );
  }
}
