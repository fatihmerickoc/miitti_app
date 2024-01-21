import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/index_page.dart';

class ActivityPageFinal extends StatefulWidget {
  const ActivityPageFinal({required this.miittiActivity, Key? key})
      : super(key: key);

  final PersonActivity miittiActivity;

  @override
  State<ActivityPageFinal> createState() => _ActivityPageFinalState();
}

class _ActivityPageFinalState extends State<ActivityPageFinal> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            height: 350.h,
            width: 350.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.lightRedColor,
                  AppColors.orangeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const IndexPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.close_rounded,
                        size: 25.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: -3.14 / 2,
                      emissionFrequency: 0.02,
                      numberOfParticles: 20,
                      gravity: 0.1,
                    ),
                    Text(
                      '🥳',
                      style: TextStyle(
                        fontSize: 100.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: Text(
                        'Miittisi on julkaistu',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0.h),
                      child: Text(
                        'Kutsu osallistujat miittiisi jakamalla linkki sosiaalisessa mediassa.',
                        style: Styles.sectionSubtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 200.w,
                      height: 50.h,
                      decoration: const BoxDecoration(
                        color: AppColors.wineColor,
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: Styles.buttonStyle,
                        child: Text(
                          'Kopioi jaettava linkki',
                          style: Styles.sectionSubtitleStyle,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const IndexPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10.0.w),
                        child: Text(
                          'Näytä miittisi',
                          style: Styles.sectionSubtitleStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
