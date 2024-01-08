import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/utils/utils.dart';

class CommercialActivity extends MiittiActivity {
  Timestamp startTime;
  Timestamp endTime;
  String hyperlink;

  String get timeString {
    return "${timestampToString(startTime)} - ${timestampToString(endTime)}";
  }

  CommercialActivity(
      {required super.activityTitle,
      required super.activityDescription,
      required super.activityCategory,
      required super.admin,
      required super.activityUid,
      required super.activityLong,
      required super.activityLati,
      required super.activityAdress,
      required this.startTime,
      required this.endTime,
      required super.isMoneyRequired,
      required super.personLimit,
      required super.participants,
      required this.hyperlink});

  static CommercialActivity fromMap(Map<String, dynamic> map) {
    var st = map['startTime'];
    var et = map['endTime'];

    if (st is String) {
      st = Timestamp.fromDate(DateTime(2023, 12, 1, 12, 08));
    }

    if (et is String) {
      et = Timestamp.fromDate(DateTime(2023, 12, 1, 12, 08));
    }

    return CommercialActivity(
      activityTitle: map['activityTitle'],
      activityDescription: map['activityDescription'],
      activityCategory: map['activityCategory'],
      admin: map['admin'],
      activityUid: map['activityUid'],
      activityLong: map['activityLong'],
      activityLati: map['activityLati'],
      activityAdress: map['activityAdress'],
      startTime: st,
      endTime: et,
      isMoneyRequired: map['isMoneyRequired'],
      personLimit: map['personLimit'],
      participants: Set<String>.from(map['participants']),
      hyperlink: map['hyperLink'],
    );
  }
}
