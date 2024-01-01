// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/adminPanel/admin_homePage.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/myProfileEditForm.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  @override
  bool get wantKeepAlive => true;

  Color miittiColor = Color.fromRGBO(255, 136, 27, 1);

  final List<String> questionOrder = [
    'Kerro millainen tyyppi olet',
    'Esittele itsesi viidellä emojilla',
    'Mikä on horoskooppisi',
    'Introvertti vai ekstrovertti',
    'Mitä ilman et voisi elää',
    'Mikä on lempiruokasi',
    'Kerro yksi fakta itsestäsi',
    'Erikoisin taito, jonka osaat',
    'Suosikkiartistisi',
    'Lempiharrastuksesi',
    'Mitä ottaisit mukaan autiolle saarelle',
    'Kerro hauskin vitsi, jonka tiedät',
    'Missä maissa olet käynyt',
    'Mikä on inhokkiruokasi',
    'Mitä tekisit, jos voittaisi miljoonan lotossa',
  ];

  List<Activity> filteredActivities = [];

  Set<String> getActivities() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return ap.miittiUser.userFavoriteActivities;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filteredActivities = activities
        .where((activity) => getActivities().contains(activity.name))
        .toList();
  }

  Widget getAdminButton(AuthProvider ap) {
    if (adminId.contains(ap.miittiUser.uid)) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AdminHomePage()));
        },
        child: Container(
          margin: EdgeInsets.only(left: 10.w),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            size: 30.r,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ap = Provider.of<AuthProvider>(context, listen: false);

    List<String> answeredQuestions = questionOrder
        .where((question) => ap.miittiUser.userChoices.containsKey(question))
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.w),
        child: AppBar(
          backgroundColor: AppColors.wineColor,
          automaticallyImplyLeading: false,
          title: Container(
            margin: EdgeInsets.only(top: 20.h, left: 10.w, right: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ap.miittiUser.userName,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyProfileEditForm(
                              user: ap.miittiUser,
                            )));
                  },
                  child: Icon(
                    Icons.settings,
                    size: 30.r,
                    color: Colors.white,
                  ),
                ),
                getAdminButton(ap),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Image.network(
                    ap.miittiUser.profilePicture,
                    height: 400.h,
                    width: 400.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 210.w,
            child: PageView.builder(
                itemCount: ap.miittiUser.userChoices.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  String question = answeredQuestions[index];
                  String answer = ap.miittiUser.userChoices[question]!;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(10.w),
                    child: Container(
                      margin: EdgeInsets.only(left: 20.w, top: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.purpleColor,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 22.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            answer,
                            maxLines: 4,
                            style: TextStyle(
                              color: Colors.black,
                              wordSpacing: 2.0,
                              fontSize: 25.sp,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            child: Container(
              height: 310.w,
              margin: EdgeInsets.only(
                left: 5.w,
                top: 10.h,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      ap.miittiUser.userArea,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      ap.miittiUser.userGender,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cake,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      calculateAge(ap.miittiUser.userBirthday).toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.g_translate,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      ap.miittiUser.userLanguages.join(', '),
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.75,
                    height: 0,
                    endIndent: 10.0,
                    indent: 10.0,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.next_week,
                      color: AppColors.lightPurpleColor,
                      size: 30.sp,
                    ),
                    title: Text(
                      ap.miittiUser.userSchool,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          SizedBox(
            height: filteredActivities.length > 3 ? 250.w : 125.w,
            child: GridView.builder(
              itemCount: filteredActivities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (context, index) {
                final activity = filteredActivities[index];
                return Container(
                  height: 100.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: [
                      Text(
                        activity.emojiData,
                        style: TextStyle(fontSize: 50.0.sp),
                      ),
                      Text(
                        activity.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 19.0.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget generateRandomString(String userName) {
    String firstLetter = userName.substring(0, 1).toLowerCase();

    if (firstLetter.compareTo('m') < 0) {
      return Text(
        '● Aktiivisenä äskettäin',
        style: TextStyle(
          color: Colors.green,
          fontSize: 15.0.sp,
          fontFamily: 'Sora',
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        '● Epäaktiivinen aiemmin',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15.0.sp,
          fontFamily: 'Sora',
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}

class Cutout extends StatelessWidget {
  const Cutout({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcOut,
      shaderCallback: (bounds) =>
          LinearGradient(colors: [color], stops: const [0.0])
              .createShader(bounds),
      child: child,
    );
  }
}
