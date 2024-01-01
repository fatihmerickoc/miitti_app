import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miitti_app/adminPanel/admin_notifications.dart';
import 'package:miitti_app/adminPanel/admin_searchMiitti.dart';
import 'package:miitti_app/adminPanel/admin_searchUser.dart';
import 'package:miitti_app/adminPanel/admin_settings.dart';
import 'package:miitti_app/constants/constants.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  //Index defined to change between different screen
  int pageIndex = 0;

  static const List<Widget> pages = <Widget>[
    AdminSearchUser(),
    AdminSearchMiitti(),
    AdminNotifications(),
    AdminSettings(),
  ];

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.h,
      ),
      color: Colors.grey,
      child: GNav(
        gap: 8.0,
        color: Colors.white,
        selectedIndex: pageIndex,
        activeColor: AppColors.purpleColor,
        onTabChange: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        tabs: [
          GButton(icon: Icons.search, iconSize: 35.sp),
          GButton(icon: Icons.window_rounded, iconSize: 35.sp),
          GButton(icon: Icons.notifications_active, iconSize: 35.sp),
          GButton(icon: Icons.settings, iconSize: 35.sp),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: _buildBottomNavBar(),
      body: pages[pageIndex],
    );
  }
}
