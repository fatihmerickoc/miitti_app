import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miitti_app/utils/utils.dart';

class MiittiActivity {
  String activityTitle;
  String activityDescription;
  String activityCategory;
  String admin;
  String activityUid;

  double activityLong;
  double activityLati;
  String activityAdress;
  Timestamp activityTime;
  bool timeDecidedLater;
  bool isMoneyRequired;

  int personLimit;

  Set<String> participants;

  Set<String> requests;

  String adminGender;
  int adminAge;

  String get timeString {
    return timeDecidedLater
        ? "Sovitaan myöhemmin"
        : timestampToString(activityTime);
  }

  MiittiActivity({
    required this.activityTitle,
    required this.activityDescription,
    required this.activityCategory,
    required this.admin,
    required this.activityUid,
    required this.activityLong,
    required this.activityLati,
    required this.activityAdress,
    required this.activityTime,
    required this.isMoneyRequired,
    required this.personLimit,
    required this.participants,
    required this.requests,
    required this.adminGender,
    required this.adminAge,
    required this.timeDecidedLater,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityTitle': activityTitle,
      'activityDescription': activityDescription,
      'activityCategory': activityCategory,
      'admin': admin,
      'activityUid': activityUid,
      'activityLong': activityLong,
      'activityLati': activityLati,
      'activityAdress': activityAdress,
      'activityTime': activityTime,
      'isMoneyRequired': isMoneyRequired,
      'personLimit': personLimit,
      'participants': participants.toList(),
      'requests': requests.toList(),
      'adminGender': adminGender,
      'adminAge': adminAge,
      'decidedLater': timeDecidedLater,
    };
  }

  static MiittiActivity fromMap(Map<String, dynamic> map) {
    var at = map['activityTime'];

    if (at is String) {
      at = Timestamp.fromDate(DateTime(2023, 12, 1, 12, 08));
    }
    return MiittiActivity(
      activityTitle: map['activityTitle'],
      activityDescription: map['activityDescription'],
      activityCategory: map['activityCategory'],
      admin: map['admin'],
      activityUid: map['activityUid'],
      activityLong: map['activityLong'],
      activityLati: map['activityLati'],
      activityAdress: map['activityAdress'],
      activityTime: at,
      isMoneyRequired: map['isMoneyRequired'],
      personLimit: map['personLimit'],
      participants: Set<String>.from(map['participants']),
      requests: Set<String>.from(map['requests']),
      adminGender: map['adminGender'] ?? "False",
      adminAge: map['adminAge'],
      timeDecidedLater: map['decidedLater'] ?? true,
    );
  }
}
