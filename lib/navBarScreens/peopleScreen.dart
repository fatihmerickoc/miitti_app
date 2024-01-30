// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/userProfileEditScreen.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  Color miittiColor = Color.fromRGBO(255, 136, 27, 1);

  late Future<List<MiittiUser>> _filteredUsersFuture;

  late Future<List<MiittiUser>> _filteredByActivitiesUsersFuture;

  late Future<List<MiittiUser>> _newestUsersFuture;

  @override
  void initState() {
    super.initState();
    _filteredUsersFuture = _fetchAndFilterUsers('area');
    _filteredByActivitiesUsersFuture = _fetchAndFilterUsers('interest');
    _newestUsersFuture = _fetchAndFilterUsers('newest');
  }

  Future<List<MiittiUser>> _fetchAndFilterUsers(String type) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    List<MiittiUser> allUsers = await ap.fetchUsers();
    if (type == 'area') {
      List<MiittiUser> filteredUsers =
          ap.filterUsersBasedOnArea(ap.miittiUser, allUsers);
      return filteredUsers;
    } else if (type == 'interest') {
      List<MiittiUser> filteredUsers =
          ap.filterUsersBasedOnInterests(ap.miittiUser, allUsers);
      return filteredUsers;
    } else {
      return allUsers.where((user) {
        if (user.uid == ap.miittiUser.uid) {
          return false; // Exclude the current user
        }

        // If there are common interests, include the user in the list
        return true;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.only(left: 20.w),
        children: [
          _buildSectionHeader("Löydä kavereita läheltä"),
          myListView('area'),
          _buildSectionHeader("Yhteisiä kiinnostuksen kohteita"),
          myListView('interest'),
          _buildSectionHeader("Miitin uudet käyttäjät"),
          myListView('newest'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontFamily: 'Rubik',
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget buildCard(MiittiUser user) {
    return Container(
      height: 225.w,
      width: 160.w,
      decoration: BoxDecoration(
        color: AppColors.wineColor,
        border: Border.all(color: AppColors.purpleColor, width: 2.0),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0.w),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 45.r,
              backgroundImage: NetworkImage(user.profilePicture),
            ),
          ),
          _buildUserInfo(user),
          SizedBox(
            height: 5.h,
          ),
          _buildElevatedButton(user),
        ],
      ),
    );
  }

  Widget buildUserActivitiesText(MiittiUser user) {
    List<String> activities = user.userFavoriteActivities.toList();
    int maxActivitiesToShow = 5;
    List<String> limitedActivities =
        activities.take(maxActivitiesToShow).toList();
    String activitiesText = limitedActivities.join(", ");
    return Text(
      activitiesText,
      maxLines: 2,
      overflow: TextOverflow.clip,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: AppColors.lightPurpleColor,
        fontFamily: 'Rubik',
      ),
    );
  }

  Widget _buildUserInfo(MiittiUser user) {
    return Column(
      children: [
        Text(
          "${user.userName}, ${calculateAge(user.userBirthday)}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontFamily: 'Rubik',
          ),
        ),
        SizedBox(height: 8.h),
        buildUserActivitiesText(user),
      ],
    );
  }

  Widget _buildElevatedButton(MiittiUser user) {
    return MyElevatedButton(
      height: 35.h,
      width: 110.w,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfileEditScreen(
                      user: user,
                    )));
      },
      child: Text(
        'Tutustu',
        style: TextStyle(
          fontFamily: 'Rubik',
          color: Colors.white,
          fontSize: 15.0.sp,
        ),
      ),
    );
  }

  Widget myListView(String type) {
    return FutureBuilder<List<MiittiUser>>(
      future: getTheFutureListView(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: AppColors.purpleColor,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred!'));
        } else {
          return SizedBox(
            height: 225.w,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return Row(
                  children: [
                    buildCard(user),
                    if (index != snapshot.data!.length - 1)
                      SizedBox(width: 20.w),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<List<MiittiUser>> getTheFutureListView(String type) {
    if (type == 'area') {
      return _filteredUsersFuture;
    } else if (type == 'interest') {
      return _filteredByActivitiesUsersFuture;
    } else {
      return _newestUsersFuture;
    }
  }
}
