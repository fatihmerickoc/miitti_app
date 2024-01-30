// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';

import 'package:toggle_switch/toggle_switch.dart';

import '../constants/constants.dart';
import 'dart:math';

enum Gender { male, female, nonBinary }

String replaceCharacters(String text) {
  text = text.replaceAll('ä', 'a');
  text = text.replaceAll('ö', 'o');

  return text;
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context, e.toString(), Colors.red.shade800);
    }
  }

  return image;
}

Widget getMiittiLogo() {
  return Container(
    margin: EdgeInsets.only(top: 40.h),
    child: Image.asset(
      'images/logo.png',
      height: 50.h,
      fit: BoxFit.cover,
    ),
  );
}

Widget getOurTextField({
  required EdgeInsets myPadding,
  FocusNode? myFocusNode,
  TextEditingController? myController,
  Function(String)? myOnChanged,
  Function()? myOnTap,
  required TextInputType myKeyboardType,
  Widget? myPrefixIcon,
  Widget? mySuffixIcon,
  String? hintText,
  int? maxLenght,
  bool myReadOnly = false,
  int maxLines = 1,
  int minLines = 1,
  double? borderRadius = 50,
  Color? borderColor = AppColors.purpleColor,
}) {
  return Padding(
    padding: myPadding,
    child: TextField(
      style: Styles.bodyTextStyle,
      focusNode: myFocusNode,
      maxLines: maxLines,
      controller: myController,
      readOnly: myReadOnly,
      onChanged: myOnChanged,
      maxLength: maxLenght,
      onTap: myOnTap,
      minLines: minLines,
      keyboardType: myKeyboardType,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.all(22.w),
        hintText: hintText,
        counterStyle: TextStyle(
          color: Colors.white,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
          borderSide: BorderSide(
            color: borderColor!,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.purpleColor,
            width: 1.5,
          ),
        ),
        prefixIcon: myPrefixIcon,
        suffixIcon: mySuffixIcon,
        hintStyle: TextStyle(
          fontSize: 21.sp,
          color: Colors.grey,
          fontFamily: 'Rubik',
        ),
      ),
    ),
  );
}

Widget getChatBubble(String text) {
  return Container(
    margin: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 10.w),
    decoration: BoxDecoration(
      color: AppColors.lightPurpleColor,
      border: Border.all(
        color: AppColors.lightPurpleColor,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(10.0),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(10.w),
      child: Text(
        text,
        style: Styles.bodyTextStyle,
      ),
    ),
  );
}

Widget getSections({
  required String title,
  required String subtitle,
  required Widget mainWidget,
}) {
  return Container(
    margin: EdgeInsets.only(top: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.sectionTitleStyle,
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          subtitle,
          style: Styles.sectionSubtitleStyle,
        ),
        SizedBox(
          height: 15.h,
        ),
        mainWidget
      ],
    ),
  );
}

Widget getGraphicImages(String imageName) {
  return Container(
    margin: EdgeInsets.only(top: 20.h),
    child: Image.asset(
      'images/$imageName.png',
      height: 250.h,
      fit: BoxFit.cover,
    ),
  );
}

String genderToString(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'Mies';
    case Gender.female:
      return 'Nainen';
    case Gender.nonBinary:
      return 'Ei-binäärinen';
    default:
      throw ArgumentError('Invalid gender value');
  }
}

int calculateAge(String birthDateString) {
  // Parse the birth date string into a DateTime object
  List<String> dateParts = birthDateString.split('/');
  int month = int.parse(dateParts[0]);
  int day = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);
  DateTime birthDate = DateTime(year, month, day);

  // Calculate the difference between the birth date and the current date
  Duration difference = DateTime.now().difference(birthDate);

  // Calculate the age of the person in years
  int age = difference.inDays ~/ 365;

  return age;
}

int daysSince(Timestamp timestamp) {
  return timestamp.toDate().difference(DateTime.now()).inDays;
}

String timestampToString(Timestamp time) {
  DateTime dateTime = time.toDate();
  print("DATETIME: $dateTime");
  return "${dateTime.day}.${dateTime.month}. ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
}

bool validatePhoneNumber(String value) {
  RegExp phoneRegex = RegExp(r"^\+\d{11,13}$");

  if (value.isEmpty) {
    return false;
  } else if (phoneRegex.hasMatch(value)) {
    return true;
  }
  return false;
}

Widget createListTile(String title) {
  return Padding(
    padding: EdgeInsets.all(8.w),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Rubik',
          fontSize: 18.sp,
        ),
      ),
      leading: Icon(
        Icons.verified_user,
        size: 30.sp,
        color: AppColors.lightRedColor,
      ),
    ),
  );
}

void pickBirthdayDate({
  required BuildContext context,
  required Function(DateTime) onDateTimeChanged,
}) {
  DateTime today = DateTime.now();
  DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month,
      today.day); // This method accounts for leap years.

  if (Platform.isIOS) {
    showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
            height: 200.h,
            color: CupertinoColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done')),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(2000, 10, 16),
                    maximumDate: eighteenYearsAgo,
                    onDateTimeChanged: onDateTimeChanged,
                  ),
                ),
              ],
            ));
      },
    );
  } else {
    showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
    ).then((selectedDate) {
      if (selectedDate != null) {
        final DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        onDateTimeChanged(selectedDateTime);
      }
    });
  }
}

void pickDate({
  required BuildContext context,
  required Function(DateTime) onDateTimeChanged,
}) async {
  DateTime initialDateTime = DateTime.now();

  DateTime maxActivityDate = DateTime(
      initialDateTime.year, initialDateTime.month, initialDateTime.day + 7);

  if (Platform.isIOS) {
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initialDateTime,
                  minimumDate: initialDateTime,
                  maximumDate: maxActivityDate,
                  onDateTimeChanged: onDateTimeChanged,
                ),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  } else {
    showDatePicker(
            context: context,
            initialDate: initialDateTime,
            firstDate: DateTime.now(),
            lastDate: maxActivityDate)
        .then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDateTime),
        ).then((selectedTime) {
          if (selectedTime != null) {
            final DateTime combinedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            onDateTimeChanged(combinedDateTime);
          }
        });
      }
    });
  }
}

Widget getMyFloatingButton({required void Function()? onPressed}) {
  return FloatingActionButton(
    onPressed: onPressed,
    backgroundColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(50)),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        gradient: LinearGradient(
          colors: [
            AppColors.lightRedColor,
            AppColors.orangeColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.add, size: 65.r),
    ),
  );
}

void showSnackBar(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: color,
    ),
  );
}

Widget createExitButton(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 55.w,
        width: 55.w,
        margin: EdgeInsets.only(left: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [
              AppColors.lightRedColor,
              AppColors.orangeColor,
            ],
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30.r,
        ),
      ),
    ),
  );
}

Widget getSomeSpace(double height) {
  return SizedBox(
    height: height.h,
  );
}

Widget getMiittiActivityText(String title) {
  return Text(
    title,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 29.sp,
      fontFamily: 'Sora',
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

String generateCustomId() {
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final String random = Random().nextInt(9999999).toString().padLeft(7, '0');
  return '$timestamp$random';
}

String twoDigits(int n) {
  if (n >= 10) {
    return "$n";
  }
  return "0$n";
}

Widget createMainToggleSwitch({
  required String text1,
  required String text2,
  required initialLabelIndex,
  required void Function(int?)? onToggle,
}) {
  return ToggleSwitch(
    minWidth: 150.w,
    minHeight: 50.h,
    initialLabelIndex: initialLabelIndex,
    cornerRadius: 50.sp,
    activeFgColor: Colors.white,
    inactiveBgColor: AppColors.wineColor,
    inactiveFgColor: Colors.white,
    totalSwitches: 2,
    curve: Curves.linear,
    customTextStyles: [
      TextStyle(
        fontSize: 14.sp,
        fontFamily: 'Rubik',
      ),
    ],
    labels: [text1, text2],
    activeBgColors: [
      [
        AppColors.lightRedColor,
        AppColors.orangeColor,
      ],
      [
        AppColors.orangeColor,
        AppColors.lightRedColor,
      ],
    ],
    onToggle: onToggle,
  );
}

String getMonthName(int monthNumber) {
  if (monthNumber < 1 || monthNumber > 12) {
    throw ArgumentError('Invalid month number: $monthNumber');
  }

  List<String> monthNames = [
    '', // Index 0 is empty since months start from 1
    'Tammikuu',
    'Helmikuu',
    'Maaliskuu',
    'Huhtikuu',
    'Toukokuu',
    'Kesäkuu',
    'Heinäkuu',
    'Elokuu',
    'Syyskuu',
    'Lokakuu',
    'Marraskuu',
    'Joulukuu',
  ];

  return monthNames[monthNumber];
}
