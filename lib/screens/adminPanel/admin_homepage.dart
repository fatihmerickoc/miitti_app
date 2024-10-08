import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants_styles.dart';

import 'package:miitti_app/screens/adminPanel/admin_notifications.dart';
import 'package:miitti_app/screens/adminPanel/admin_search_miitti.dart';
import 'package:miitti_app/screens/adminPanel/admin_search_user.dart';
import 'package:miitti_app/screens/adminPanel/admin_settings.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  //Index defined to change between different screen
  int _pageIndex = 0;

  static const List<Widget> pages = <Widget>[
    AdminSearchUser(),
    AdminSearchMiitti(),
    AdminNotifications(),
    AdminSettings(),
  ];

  Widget _buildBottomNavBar() {
    return CustomNavigationBar(
      iconSize: 35.sp,
      selectedColor: ConstantStyles.pink,
      unSelectedColor: Colors.white,
      strokeColor: ConstantStyles.black.withOpacity(0.9),
      backgroundColor: ConstantStyles.black.withOpacity(0.9),
      items: [
        CustomNavigationBarItem(
          icon: const Icon(Icons.search),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.window_rounded),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.notifications_active),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.settings),
        ),
      ],
      currentIndex: _pageIndex,
      onTap: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: _buildBottomNavBar(),
      body: pages[_pageIndex],
    );
  }
}
