import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/utils/utils.dart';

class AdBanner {
  String image;
  String link;
  Set<String> targetActivities;
  int targetMinAge;
  int targetMaxAge;
  bool targetMen;
  bool targetWomen;
  bool targetNonBinary;

  AdBanner({
    required this.image,
    required this.link,
    required this.targetActivities,
    required this.targetMinAge,
    required this.targetMaxAge,
    required this.targetMen,
    required this.targetWomen,
    required this.targetNonBinary,
  });

  factory AdBanner.fromMap(Map<String, dynamic> map) {
    return AdBanner(
      image: map['image'] ?? '',
      link: map['link'] ?? '',
      targetActivities: (map['targetActivities'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      targetMinAge: map['targetMinAge'] ?? 18,
      targetMaxAge: map['targetMaxAge'] ?? 80,
      targetMen: map['targetMen'] ?? true,
      targetWomen: map['targetWomen'] ?? true,
      targetNonBinary: map['targetNonBinary'] ?? true,
    );
  }

  bool targetUser(MiittiUser user) {
    int age = calculateAge(user.userBirthday);
    if (age < targetMinAge || age > targetMaxAge) return false;

    if (user.userGender == "Mies" && !targetMen) return false;
    if (user.userGender == "Nainen" && !targetMen) return false;
    if (user.userGender == "Ei-binäärinen" && !targetMen) return false;

    bool suitable = false;
    for (var activity in targetActivities) {
      if (user.userFavoriteActivities.contains(activity)) suitable = true;
    }

    return suitable;
  }

  bool targetCommon(MiittiUser user, MiittiUser another) {
    return targetUser(user) && targetUser(another);
  }
}
