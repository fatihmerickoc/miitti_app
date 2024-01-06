class UserReport {
  String uid;
  List<String> reasons;

  UserReport({required this.uid, required this.reasons});

  factory UserReport.fromMap(Map<String, dynamic> map) {
    return UserReport(
        uid: map["uid"] ?? '',
        reasons: (map['reasons'] as List<dynamic>? ?? []).cast<String>());
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'reasons': reasons,
    };
  }
}
