class MiittiUser {
  String userEmail;
  String userName;
  String userPhoneNumber;
  String userBirthday;
  String userArea;
  Set<String> userFavoriteActivities;
  Map<String, String> userChoices;
  String userGender;
  Set<String> userLanguages;
  String profilePicture;
  String uid;
  Set<String> invitedActivities;
  String userStatus;
  String userSchool;
  String fcmToken;

  MiittiUser(
      {required this.userName,
      required this.userEmail,
      required this.uid,
      required this.userPhoneNumber,
      required this.userBirthday,
      required this.userArea,
      required this.userFavoriteActivities,
      required this.userChoices,
      required this.userGender,
      required this.userLanguages,
      required this.profilePicture,
      required this.invitedActivities,
      required this.userStatus,
      required this.userSchool,
      required this.fcmToken});

  factory MiittiUser.fromMap(Map<String, dynamic> map) {
    return MiittiUser(
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      uid: map['uid'] ?? '',
      userPhoneNumber: map['userPhoneNumber'] ?? '',
      userBirthday: map['userBirthday'] ?? '',
      userArea: map['userArea'] ?? '',
      userFavoriteActivities:
          (map['userFavoriteActivities'] as List<dynamic>? ?? [])
              .cast<String>()
              .toSet(),
      userChoices: (map['userChoices'] as Map<String, dynamic>? ?? {})
          .cast<String, String>(),
      userGender: map['userGender'] ?? '', // Updated to single File
      userLanguages:
          (map['userLanguages'] as List<dynamic>? ?? []).cast<String>().toSet(),
      profilePicture: map['profilePicture'] ?? '',
      invitedActivities: (map['invitedActivities'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      userStatus: map['userStatus'] ?? '',
      userSchool: map['userSchool'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    var ul = userLanguages.toList();
    if (ul.contains('🇬🇧')) {
      int index = ul.indexOf('🇬🇧');
      ul[index] = '🇪🇳';
    }

    userLanguages = ul.toSet();

    return {
      'userName': userName,
      'userEmail': userEmail,
      'uid': uid,
      'userPhoneNumber': userPhoneNumber,
      'userBirthday': userBirthday,
      'userArea': userArea,
      'userFavoriteActivities': userFavoriteActivities.toList(),
      'userChoices': userChoices,
      'userGender': userGender,
      'userLanguages': ul,
      'profilePicture': profilePicture,
      'invitedActivities': invitedActivities.toList(),
      'userStatus': userStatus,
      'userSchool': userSchool,
      'fcmToken': fcmToken,
    };
  }

  Set<String> fixLanguages(List<String> list) {
    if (list.contains('🇬🇧')) {
      int index = list.indexOf('🇬🇧');
      list[index] = '🇪🇳';
    }
    return list.toSet();
  }
}
