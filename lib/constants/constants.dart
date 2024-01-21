import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/helpers/activity.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFF090215);
  static const Color whiteColor = Color(0xFFFFFBF7);
  static const Color mixGradientColor = Color(0xFFEC5800);
  static const Color lavenderColor = Color(0xFFE6E6FA);
  static const Color darkPurpleColor = Color(0xFF220060);
  static const Color purpleColor = Color(0xFF5615CE);
  static const Color lightPurpleColor = Color(0xFFC3A3FF);
  static const Color yellowColor = Color(0xFFFED91E);
  static const Color orangeColor = Color(0xFFF17517);
  static const Color lightOrangeColor = Color(0xFFF59B57);
  static const Color darkOrangeColor = Color(0xFFF27052);
  static const Color lightRedColor = Color(0xFFF36269);
  static const Color pinkColor = Color(0xFFF45087);
  static const Color wineColor = Color(0xFF180B31);
  static const Color transparentPurple = Color.fromARGB(100, 86, 21, 206);
}

class Styles {
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
  );

  static TextStyle titleTextStyle = TextStyle(
    fontSize: 26.sp,
    fontFamily: 'Sora',
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle activityNameTextStyle = TextStyle(
    fontFamily: 'Rubik',
    fontSize: 19.sp,
    color: AppColors.whiteColor,
  );
  static TextStyle bodyTextStyle = TextStyle(
    fontSize: 21.sp,
    color: AppColors.whiteColor,
    fontFamily: 'Rubik',
  );

  static TextStyle sectionTitleStyle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteColor,
  );

  static TextStyle sectionSubtitleStyle = TextStyle(
    fontFamily: 'Rubik',
    fontSize: 14.sp,
    color: AppColors.whiteColor,
  );
}

List<Activity> activities = [
  Activity(name: 'Mailapeleille', emojiData: '🏸'),
  Activity(name: 'Bilettämään', emojiData: '🎉'),
  Activity(name: 'Festareille', emojiData: '💃'),
  Activity(name: 'Golfaamaan', emojiData: '⛳️'),
  Activity(name: 'Hengailemaan', emojiData: '💬'),
  Activity(name: 'Pallopeleille', emojiData: '⚽️'),
  Activity(name: 'Kahville', emojiData: '☕️'),
  Activity(name: 'Konserttiin', emojiData: '🎫'),
  Activity(name: 'Lasilliselle', emojiData: '🥂'),
  Activity(name: 'Lautapelit', emojiData: '🎲'),
  Activity(name: 'Leffaan', emojiData: '🎥'),
  Activity(name: 'Liikkumaan', emojiData: '👟'),
  Activity(name: 'Matkaseuraa', emojiData: '✈️'),
  Activity(name: 'Opiskelemaan', emojiData: '📚'),
  Activity(name: 'Pelaamaan', emojiData: '🕹️'),
  Activity(name: 'Pyöräilemään', emojiData: '🚲'),
  Activity(name: 'Seikkailemaan', emojiData: '🚀'),
  Activity(name: 'Skeittaamaan', emojiData: '🛹'),
  Activity(name: 'Syömään', emojiData: '🍔'),
  Activity(name: 'Näyttelyyn', emojiData: '🏛️'),
  Activity(name: 'Teatteriin', emojiData: '🎭'),
  Activity(name: 'Uimaan', emojiData: '🏊‍♂️'),
  Activity(name: 'Ulkoilemaan', emojiData: '🌳'),
  Activity(name: 'Valokuvaamaan', emojiData: '📸'),
  Activity(name: 'Laskettelemaan', emojiData: '🏂'),
  Activity(name: 'Retkeilemään', emojiData: '🏕️'),
  Activity(name: "Salille", emojiData: '🏋️'),
  Activity(name: "Luistelemaan", emojiData: '⛸️'),
  Activity(name: "Roadtripille", emojiData: '🚘'),
  Activity(name: "Kiipeilemään", emojiData: '🧗‍♂️'),
  Activity(name: "Keilaamaan", emojiData: '🎳')
];

List<Activity> commercialActivities = [
  Activity(name: 'Liikunta', emojiData: '👟'),
  Activity(name: 'Bileet', emojiData: '🎉'),
  Activity(name: 'Festivaalit', emojiData: '💃'),
  Activity(name: 'Konsertti', emojiData: '🎫'),
  Activity(name: 'Ruoka', emojiData: '🍔'),
  Activity(name: 'Kahvila', emojiData: '☕️'),
  Activity(name: 'Taidenäyttely', emojiData: '🎨'),
  Activity(name: 'Työpaja', emojiData: '🔨'),
  Activity(name: 'Verkostoituminen', emojiData: '💬'),
  Activity(name: 'Muu kulttuuritapahtuma', emojiData: '🎭'),
  Activity(name: 'Muu tapahtuma', emojiData: '🥂'),
  Activity(name: 'Muu aktiviteetti', emojiData: '🎲'),
];

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

final List<String> languages = [
  '🇫🇮',
  '🇸🇪',
  '🇬🇧',
];

final List<String> cities = [
  "Helsinki",
  "Espoo",
  "Tampere",
  "Vantaa",
  "Oulu",
  "Turku",
  "Jyväskylä",
  "Lahti",
  "Kuopio",
  "Pori",
  "Kouvola",
  "Joensuu",
  "Lappeenranta",
  "Hämeenlinna",
  "Vaasa",
  "Seinäjoki",
  "Rovaniemi",
  "Mikkeli",
  "Kotka",
  "Salo"
];

final List<String> adminId = [
  'GLaTiyhEYvSBtCdms5zPR7TIlOB3',
  '43uacOhSQKOBxXEsEzTucaN7b5B2',
  'PCgz01aA7nbGAQigFsKyFnrHpMF2',
  'cyn5uJdDskdwGaZDvmNtztfxsRm2',
  'TI4jAfRnjnUWM46zwsL4pYUrF3Z2',
];
