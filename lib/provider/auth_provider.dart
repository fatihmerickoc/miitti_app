// ignore_for_file: use_build_context_synchronously

// #region depedencies
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:miitti_app/chatPage.dart';
import 'package:miitti_app/commercialScreens/comact_detailspage.dart';
import 'package:miitti_app/commercialScreens/comchat_page.dart';
import 'package:miitti_app/constants/ad_banner.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/commercial_spot.dart';
import 'package:miitti_app/constants/commercial_user.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/constants/report.dart';
import 'package:miitti_app/createMiittiActivity/activityDetailsPage.dart';
import 'package:miitti_app/createMiittiActivity/activityPageFinal.dart';
import 'package:miitti_app/helpers/filter_settings.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/onboardingScreens/obs3_sms.dart';
import 'package:miitti_app/onboardingScreens/onboarding.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
// #endregion

class AuthProvider extends ChangeNotifier {
// #region Variables

  static const String _usersString = "users";
  static const String _activitiesString = "activities";
  static const String _comactString = "commercialActivities";

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String? _uid;
  String get uid => _uid!;
  bool get userNull => _uid == null;

  MiittiUser? _miittiUser;
  MiittiUser get miittiUser => _miittiUser!;

  PersonActivity? _miittiActivity;
  PersonActivity get miittiActivity => _miittiActivity!;

  AuthProvider() {
    checkSign();
  }

// #endregion

// #region SignIn
  Future<bool> checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool('is_signedin') ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  Future setSignIn() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setBool('is_signedin', true);
    _isSignedIn = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      startLoading();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          User? user =
              (await _firebaseAuth.signInWithCredential(phoneAuthCredential))
                  .user;
          _uid = user?.uid;

          showSnackBar(
              context, "Koodi saatu automaattisesti!", Colors.green.shade600);

          checkExistingUser().then((value) async {
            if (value == true) {
              getDataFromFirestore().then(
                (value) => saveUserDataToSP().then(
                  (value) => setSignIn().then(
                    (value) => pushNRemoveUntil(context, const IndexPage()),
                  ),
                ),
              );
            } else {
              pushNRemoveUntil(context, const OnboardingScreen());
            }
          });
          stopLoading();
          debugPrint("$phoneNumber signed in");
        },
        verificationFailed: (error) {
          stopLoading();
          showSnackBar(context, "Failed phone verification: $error",
              Colors.red.shade800);

          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          stopLoading();
          debugPrint("sending code to $phoneNumber");
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OnBordingScreenSms(
                  verificationId: verificationId,
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      stopLoading();
      debugPrint("Kirjautuminen epäonnistui: ${e.message}");
      showSnackBar(context, "Kirjautuminen epäonnistui: ${e.message}",
          Colors.red.shade800);
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    startLoading();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;
      _uid = user?.uid;

      onSuccess();
    } on FirebaseAuthException catch (e) {
      print("Vahvistus epäonnistui: ${e.message} (${e.code})");
      showSnackBar(context, 'SMS vahvistus epäonnistui ${e.message}',
          Colors.red.shade800);
    } finally {
      stopLoading();
    }
  }

// #endregion

// #region Report

  Future<void> reportUser(
      String message, String reportedId, String senderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot documentSnapshot =
          await _fireStore.collection('reportedUsers').doc(reportedId).get();

      Report report;
      if (documentSnapshot.exists) {
        report = Report.fromMap(
            documentSnapshot.data() as Map<String, dynamic>, true);
        report.reasons.add("$senderId: $message");
      } else {
        report = Report(
          reportedId: reportedId,
          reasons: ["$senderId: $message"],
          isUser: true,
        );
      }
      await _fireStore
          .collection('reportedUsers')
          .doc(reportedId)
          .set(report.toMap());
    } catch (e) {
      print("Reporting failed: $e");
    } finally {
      Timer(const Duration(seconds: 1), () {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> reportActivity(
      String message, String reportedId, String senderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot documentSnapshot = await _fireStore
          .collection('reportedActivities')
          .doc(reportedId)
          .get();

      Report report;
      if (documentSnapshot.exists) {
        report = Report.fromMap(
            documentSnapshot.data() as Map<String, dynamic>, false);
        report.reasons.add("$senderId: $message");
      } else {
        report = Report(
          reportedId: reportedId,
          reasons: ["$senderId: $message"],
          isUser: false,
        );
      }
      await _fireStore
          .collection('reportedActivities')
          .doc(reportedId)
          .set(report.toMap());
    } catch (e) {
      print("Reporting failed: $e");
    } finally {
      Timer(const Duration(seconds: 1), () {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<List<PersonActivity>> fetchReportedActivities() async {
    try {
      QuerySnapshot querySnapshot = await _getFireQuery('reportedActivities');

      List<PersonActivity> list = [];

      for (QueryDocumentSnapshot report in querySnapshot.docs) {
        DocumentSnapshot doc = await _getActivityDoc(report.id);
        list.add(PersonActivity.fromMap(doc.data() as Map<String, dynamic>));
      }

      return list;
    } catch (e) {
      print('Error fetching reported activities: $e');
      return [];
    }
  }

// #endregion

// #region Ads
  Future<List<AdBanner>> fetchAds() async {
    try {
      QuerySnapshot querySnapshot = await _getFireQuery('adBanners');

      List<AdBanner> list = querySnapshot.docs
          .map((doc) => AdBanner.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return AdBanner.sortBanners(list, miittiUser);
    } catch (e) {
      print("Error fetching ads $e");
      return [];
    }
  }

  void addAdView(String adUid) async {
    try {
      await _fireStore.collection('adBanners').doc(adUid).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding view: $e');
    }
  }

  void addAdClick(String adUid) async {
    try {
      await _fireStore.collection('adBanners').doc(adUid).update({
        'clicks': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding view: $e');
    }
  }
// #endregion

// #region Activities

  void saveMiittiActivityDataToFirebase({
    required BuildContext context,
    required PersonActivity activityModel,
  }) async {
    startLoading();
    try {
      activityModel.admin = _miittiUser!.uid;
      activityModel.adminAge = calculateAge(_miittiUser!.userBirthday);
      activityModel.adminGender = _miittiUser!.userGender;
      activityModel.activityUid = generateCustomId();
      activityModel.participants.add(_miittiUser!.uid);

      _miittiActivity = activityModel;

      await _activityDocRef(activityModel.activityUid)
          .set(activityModel.toMap())
          .then((value) {
        pushNRemoveUntil(
          context,
          ActivityPageFinal(
            miittiActivity: _miittiActivity!,
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString(), Colors.red.shade800);
    } finally {
      stopLoading();
    }
  }

  Future<List<MiittiActivity>> fetchActivities() async {
    startLoading();
    try {
      FilterSettings filterSettings = FilterSettings();
      await filterSettings.loadPreferences();

      QuerySnapshot querySnapshot = await _getFireQuery(_activitiesString);

      List<MiittiActivity> activities = querySnapshot.docs
          .map((doc) => PersonActivity.fromDoc(doc))
          .where((activity) {
        if (_miittiUser == null) {
          print("User is null");
        } else {
          print("Checking filters of ${_miittiUser?.userName}");
          if (daysSince(activity.activityTime) <
              (activity.timeDecidedLater ? -14 : -1)) {
            removeActivity(activity.activityUid);
            return false;
          }

          if (filterSettings.sameGender &&
              activity.adminGender != miittiUser.userGender) {
            return false;
          }
          if (!filterSettings.multiplePeople && activity.personLimit > 2) {
            return false;
          }
          if (activity.adminAge < filterSettings.minAge ||
              activity.adminAge > filterSettings.maxAge) {
            return false;
          }
        }

        return true;
      }).toList();

      QuerySnapshot commercialQuery = await _getFireQuery(_comactString);

      List<MiittiActivity> comActivities = commercialQuery.docs
          .map((doc) => CommercialActivity.fromDoc(doc))
          .where((activity) {
        if (_miittiUser == null) {
          print("User is null");
        } else {
          print("Checking filters of ${_miittiUser?.userName}");
          if (daysSince(activity.endTime) < -1) {
            return false;
          }
        }

        return true;
      }).toList();

      List<MiittiActivity> list = List<MiittiActivity>.from(activities);
      list.addAll(List<MiittiActivity>.from(comActivities));
      return list;
    } catch (e, s) {
      print('Error fetching activities: $e');
      print(s);
      return [];
    } finally {
      stopLoading();
    }
  }

  Future<List<MiittiActivity>> fetchUserActivities() async {
    startLoading();
    try {
      QuerySnapshot querySnapshot =
          await _queryWhereContains(_activitiesString, 'participants', uid);

      QuerySnapshot commercialSnapshot =
          await _queryWhereContains(_comactString, 'participants', uid);

      QuerySnapshot requestSnapshot =
          await _queryWhereContains(_activitiesString, "requests", uid);

      List<PersonActivity> personActivities = [];
      List<CommercialActivity> commercialActivities = [];

      for (var doc in querySnapshot.docs) {
        personActivities.add(PersonActivity.fromDoc(doc));
      }

      for (var doc in commercialSnapshot.docs) {
        commercialActivities.add(CommercialActivity.fromDoc(doc));
      }

      for (var doc in requestSnapshot.docs) {
        personActivities.add(PersonActivity.fromDoc(doc));
      }

      DocumentSnapshot documentSnapshot = await _getUserDoc(uid);

      MiittiUser myOwnUser = MiittiUser.fromDoc(documentSnapshot);

      if (myOwnUser.invitedActivities.isNotEmpty) {
        for (String activityId in myOwnUser.invitedActivities) {
          DocumentSnapshot activitySnapshot = await _getActivityDoc(activityId);

          if (activitySnapshot.exists) {
            PersonActivity activity = PersonActivity.fromMap(
                activitySnapshot.data() as Map<String, dynamic>);
            personActivities.add(activity);
          }
        }
      }

      List<MiittiActivity> list = List<MiittiActivity>.from(personActivities);
      list.addAll(List<MiittiActivity>.from(commercialActivities));
      return list;
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

  Future removeActivity(String activityId) async {
    startLoading();
    try {
      await _activityDocRef(activityId)
          .delete()
          .then((value) => print("Activity Removed!"));
    } catch (e) {
      print('Error deleting activity: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

  Future<List<PersonActivity>> fetchAdminActivities() async {
    startLoading();
    try {
      QuerySnapshot querySnapshot =
          await _queryWhereEquals(_activitiesString, 'admin', uid);

      List<PersonActivity> activities =
          querySnapshot.docs.map((doc) => PersonActivity.fromDoc(doc)).toList();

      return activities;
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

  Future<int> adminActivitiesLength() async {
    startLoading();
    try {
      QuerySnapshot querySnapshot =
          await _queryWhereEquals(_activitiesString, 'admin', uid);

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching user activities: $e');
      return 0;
    } finally {
      stopLoading();
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivitiesRequests() async {
    startLoading();

    try {
      QuerySnapshot querySnapshot =
          await _queryWhereEquals(_activitiesString, 'admin', uid);

      List<PersonActivity> activities =
          querySnapshot.docs.map((doc) => PersonActivity.fromDoc(doc)).toList();

      List<Map<String, dynamic>> usersAndActivityIds = [];

      for (PersonActivity activity in activities) {
        List<MiittiUser> users = await fetchUsersByUids(activity.requests);
        usersAndActivityIds.addAll(users.map((user) => {
              'user': user,
              'activity': activity,
            }));
      }

      return usersAndActivityIds.toList();
    } catch (e) {
      print('Error fetching admin activities: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

  Future<List<PersonActivity>> fetchActivitiesRequestsFrom(
      String userId) async {
    try {
      startLoading();

      QuerySnapshot querySnapshot = await _fireStore
          .collection('activities')
          .where('admin', isEqualTo: uid)
          .where('requests', arrayContains: userId)
          .get();

      List<PersonActivity> activities =
          querySnapshot.docs.map((doc) => PersonActivity.fromDoc(doc)).toList();
      return activities;
    } catch (e) {
      print('Error fetching admin activities: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

  Future<MiittiActivity> getSingleActivity(String activityId) async {
    _isLoading = true;
    notifyListeners();
    MiittiActivity activity;

    activity = await _personalOrCommercial(activityId, (a) {}, (comA) {});

    stopLoading();
    return activity;
  }

  Future<Widget> getDetailsPage(String activityId) async {
    startLoading();
    try {
      Widget widget = const IndexPage();
      await _personalOrCommercial(
          activityId,
          (activity) => widget = ActivityDetailsPage(myActivity: activity),
          (comActivity) => widget = ComActDetailsPage(myActivity: comActivity));
      return widget;
    } catch (e) {
      print('Error getting details page: $e');
      return const IndexPage();
    } finally {
      stopLoading();
    }
  }

  Future<List<CommercialSpot>> fetchCommercialSpots() async {
    startLoading();
    try {
      QuerySnapshot querySnapshot = await _getFireQuery('commercialSpots');

      List<CommercialSpot> spots = querySnapshot.docs
          .map((doc) =>
              CommercialSpot.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return spots;
    } catch (e) {
      print('Error fetching commercial spots: $e');
      return [];
    } finally {
      stopLoading();
    }
  }

// #endregion

// #region UsersInActivities

  Future<void> sendActivityRequest(String activityId) async {
    try {
      startLoading();

      await _activityDocRef(activityId).update({
        'requests': FieldValue.arrayUnion([_uid])
      }).then((value) {
        print("User joined the activity successfully");
      }).catchError((error) {
        print("Error joining the activity: $error");
      });
    } catch (e) {
      print('Error while joining activity: $e');
    } finally {
      Timer(const Duration(seconds: 1), () {
        stopLoading();
      });
    }
  }

  Future<void> joinActivity(String activityId) async {
    try {
      startLoading();

      await _comActivityDocRef(activityId).update({
        'participants': FieldValue.arrayUnion([_uid])
      }).then((value) {
        print("User joined the activity successfully");
      }).catchError((error) {
        print("Error joining the activity: $error");
      });
    } catch (e) {
      print('Error while joining activity: $e');
    } finally {
      Timer(const Duration(seconds: 1), () {
        stopLoading();
      });
    }
  }

  Future<bool> reactToInvite(String activityId, bool accepted) async {
    startLoading();
    bool operationCompleted = false;
    try {
      await _tryGetUser(uid, (user) async {
        user.invitedActivities.remove(activityId);
        await _userDocRef(uid)
            .update({'invitedActivities': user.invitedActivities.toList()});
        if (accepted) {
          await updateUserJoiningActivity(activityId, uid, true);
          operationCompleted = true;
        }
      }, () {});
    } catch (e) {
      print('Found error accepting invite: $e');
    } finally {
      stopLoading();
    }
    return operationCompleted;
  }

  Future inviteUserToYourActivity(
    String userId,
    String activityId,
  ) async {
    startLoading();

    try {
      await _tryGetUser(uid, (user) async {
        user.invitedActivities.add(activityId);
        await _userDocRef(userId)
            .update({'invitedActivities': user.invitedActivities.toList()});
      }, () {});

      stopLoading();
    } catch (e) {
      stopLoading();
      debugPrint('Got this error while inviting user to your activity $e');
    }
  }

  Future<bool> checkIfUserJoined(String activityUid,
      {bool commercial = false}) async {
    startLoading();
    final snapshot = await _fireStore
        .collection(commercial ? 'commercialActivities' : 'activities')
        .doc(activityUid)
        .get();

    stopLoading();

    if (snapshot.exists) {
      final activity = commercial
          ? CommercialActivity.fromDoc(snapshot)
          : PersonActivity.fromDoc(snapshot);
      return activity.participants.contains(uid);
    }

    return false;
  }

  Future<UserStatusInActivity> getUserStatusInActivity(
      String activityUid) async {
    startLoading();
    try {
      final snapshot = await _getActivityDoc(activityUid);

      if (snapshot.exists) {
        final activity = PersonActivity.fromDoc(snapshot);
        if (activity.participants.contains(uid)) {
          return UserStatusInActivity.joined;
        } else if (activity.requests.contains(uid)) {
          return UserStatusInActivity.requested;
        }
      }

      return UserStatusInActivity.none;
    } catch (e) {
      print('Error getting user status in activity: $e');
      return UserStatusInActivity.none;
    } finally {
      stopLoading();
    }
  }

  Future<bool> checkIfUserRequested(String activityUid) async {
    final snapshot = await _getActivityDoc(activityUid);

    if (snapshot.exists) {
      final activity = PersonActivity.fromDoc(snapshot);
      return activity.requests.contains(uid);
    }

    return false;
  }

  Future<bool> updateUserJoiningActivity(
    String activityId,
    String userId,
    bool accept,
  ) async {
    startLoading();
    bool joined = false;

    try {
      final activityRef = _fireStore.collection('activities').doc(activityId);

      await _fireStore.runTransaction((transaction) async {
        final activitySnapshot = await transaction.get(activityRef);
        if (!activitySnapshot.exists) {
          print('Activity does not exist.');
          return;
        }

        final activityData = activitySnapshot.data();
        final List<dynamic> participants = activityData?['participants'];
        final List<dynamic> requests = activityData?['requests'];

        // Remove user ID from requests
        requests.remove(userId);

        // Add user ID to participants if not already present
        if (!participants.contains(userId) && accept) {
          participants.add(userId);
          joined = true;
        }

        transaction.update(activityRef, {
          'participants': participants,
          'requests': requests,
        });
      });

      stopLoading();
    } catch (e) {
      stopLoading();
      print('Error while joining activity: $e');
    }
    return joined;
  }

  Future<void> removeUserFromActivity(
    String activityId,
    bool isRequested,
  ) async {
    startLoading();
    try {
      if (!isRequested) {
        //check if activity or commercial activity
        DocumentReference activityRef = _activityDocRef(activityId);
        DocumentSnapshot snapshot = await activityRef.get();

        if (snapshot.exists) {
          await activityRef.update({
            'participants': FieldValue.arrayRemove([uid])
          });
        } else {
          await _comActivityDocRef(activityId).update({
            'participants': FieldValue.arrayRemove([uid])
          });
        }
      } else {
        await _activityDocRef(activityId).update({
          'requests': FieldValue.arrayRemove([uid])
        });
      }

      print("User removed from activity successfully.");
    } catch (e) {
      print('Error removing user from activity: $e');
    } finally {
      stopLoading();
    }
  }

  Future getGroupAdmin(String activityId) async {
    DocumentSnapshot documentSnapshot = await _getActivityDoc(activityId);
    return documentSnapshot['admin'];
  }

// #endregion

// #region Chatting

  Future<Widget> getChatPage(String activityId) async {
    startLoading();
    try {
      Widget widget = const IndexPage();

      await _personalOrCommercial(
          activityId,
          (a) => widget = ChatPage(activity: a),
          (comA) => widget = ComChatPage(activity: comA));

      return widget;
    } catch (e) {
      print('Error getting chat page: $e');
      return const IndexPage();
    } finally {
      stopLoading();
    }
  }

  getChats(String activityId, [bool commercial = false]) async {
    DocumentReference docRef = commercial
        ? _comActivityDocRef(activityId)
        : _activityDocRef(activityId);
    return docRef
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  void sendMessage(String activityId, Map<String, dynamic> chatMessageData,
      [bool commercial = false]) async {
    DocumentReference docRef = commercial
        ? _comActivityDocRef(activityId)
        : _activityDocRef(activityId);
    await docRef.collection("messages").add(chatMessageData);

    await docRef.update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

// #endregion

// #region ThisUser

  Future<bool> checkExistingUser() async {
    return await _tryGetUser(uid, (user) {}, () {});
  }

  void saveUserDatatoFirebase({
    required BuildContext context,
    required MiittiUser userModel,
    required File? image,
    required Function onSucess,
  }) async {
    startLoading();
    try {
      await uploadUserImage(_firebaseAuth.currentUser!.uid, image)
          .then((value) {
        userModel.profilePicture = value;
      }).onError((error, stackTrace) {});
      userModel.userPhoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      userModel.uid = _firebaseAuth.currentUser!.uid;
      _miittiUser = userModel;

      await _userDocRef(uid).set(userModel.toMap()).then((value) {
        onSucess();
        stopLoading();
      }).onError(
        (error, stackTrace) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString(), Colors.red.shade800);
      print("Userdata to firebase error: $e");
      stopLoading();
    }
  }

  Future<String> uploadUserImage(String uid, File? image) async {
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      // contentType: 'image/png',
      customMetadata: {'picked-file-path': image!.path},
    );

    String filePath = 'userImages/$uid/profilePicture.jpg';
    try {
      final UploadTask uploadTask;
      Reference ref = FirebaseStorage.instance.ref(filePath);

      uploadTask = ref.putData(await image.readAsBytes(), metadata);

      String imageUrl = await (await uploadTask).ref.getDownloadURL();

      return imageUrl;
    } catch (error) {
      throw Exception("Upload failed: $error");
    }
  }

  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('user_model', json.encode(miittiUser.toMap()));
  }

  Future getDataFromSp() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString('user_model') ?? '';
    _miittiUser = MiittiUser.fromMap(jsonDecode(data));
    _uid = _miittiUser!.uid;
    notifyListeners();
  }

  Future getDataFromFirestore() async {
    await _getUserDoc(_firebaseAuth.currentUser!.uid)
        .then((DocumentSnapshot snapshot) {
      _miittiUser = MiittiUser(
          userName: snapshot['userName'],
          userEmail: snapshot['userEmail'],
          uid: snapshot['uid'],
          userPhoneNumber: snapshot['userPhoneNumber'],
          userBirthday: snapshot['userBirthday'],
          userArea: snapshot['userArea'],
          userFavoriteActivities:
              (snapshot['userFavoriteActivities'] as List<dynamic>)
                  .cast<String>()
                  .toSet(),
          userChoices: (snapshot['userChoices'] as Map<String, dynamic>)
              .cast<String, String>(),
          userGender: snapshot['userGender'],
          userLanguages: (snapshot['userLanguages'] as List<dynamic>)
              .cast<String>()
              .toSet(),
          profilePicture: snapshot['profilePicture'],
          invitedActivities: (snapshot['invitedActivities'] as List<dynamic>)
              .cast<String>()
              .toSet(),
          userStatus: snapshot['userStatus'],
          userSchool: snapshot['userSchool'],
          fcmToken: snapshot['fcmToken'],
          userRegistrationDate: snapshot['userRegistrationDate']);
      _uid = _miittiUser!.uid;
    }).onError((error, stackTrace) {
      print('ERROR: ${error.toString()}');
    });
  }

  Future<void> setUserStatus() async {
    try {
      DateTime now = DateTime.now().toUtc();
      String timestampString = now.toIso8601String();
      await _userDocRef(uid).update({'userStatus': timestampString});
      print("Userstatus set");
    } catch (e, s) {
      if (_uid == null) print("UID is null");
      print('Got an error setting user status $e and my uid is $_uid');
      print('$s');
    }
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

  Future updateUserInfo(MiittiUser updatedUser, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (imageFile != null) {
        await uploadUserImage(_firebaseAuth.currentUser!.uid, imageFile)
            .then((value) {
          updatedUser.profilePicture = value;
        }).onError((error, stackTrace) {
          print("HATA UPDATEUSERINFO: $error");
        });
      }

      await _fireStore
          .collection('users')
          .doc(_uid)
          .update(updatedUser.toMap())
          .then((value) {
        _miittiUser = updatedUser;
      });

      // Update the user in the provider
      stopLoading();
    } on FirebaseAuthException catch (e) {
      print('Error updating user info: ${e.message}');
    }
  }

  Future<(bool logOut, String message)> removeUser(String userId) async {
    startLoading();

    //Deleting user image from storage
    try {
      await FirebaseStorage.instance
          .ref('userImages/$userId/profilePicture.jpg')
          .delete();
      print("Deleted from storage");
    } catch (e, s) {
      stopLoading();
      print("Error removing user image from storage: $e");
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'a non-fatal error');
      return (
        false,
        "Profiilikuvan poistaminen palvelimelta epäonnistui.\nOle yhteydessä tukeen."
      );
    }

    //Deleting userdata from firestore
    try {
      await _userDocRef(userId).delete();
      print("Deteted from firestore");
    } catch (e, s) {
      stopLoading();
      print("Error removing user from firestore: $e");
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'a non-fatal error');
      return (
        false,
        "Profiilin poistaminen palvelimelta epäonnistui.\nOle yhteydessä tukeen."
      );
    }

    //Deleting user from auth
    try {
      if (!adminId.contains(_firebaseAuth.currentUser!.uid) &&
          _firebaseAuth.currentUser!.uid.isNotEmpty) {
        await _firebaseAuth.currentUser?.delete();
        print("deleted from auth");
      }
    } catch (e, s) {
      stopLoading();
      print("Error removing user from auth: $e");
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'a non-fatal error');
      return (
        false,
        "Profiili poistettiin palvelimelta mutta kirjautumistietojen poistaminen epäonnistui.\nOle yhteydessä tukeen."
      );
    }

    try {
      if (!adminId.contains(userId)) {
        SharedPreferences s = await SharedPreferences.getInstance();
        _isSignedIn = false;
        await s.clear().then((v) {
          if (v) {
            print("deleted from shared pref");
          } else {
            print("not deleted from shared pref");
            stopLoading();
            return (
              false,
              "Tilisi on poistettu palvelimelta, mutta tietojen poistaminen puhelimelta epäonnistui.\n Poista sovelluksen tiedot puhelimen asetuksista."
            );
          }
        });
      }
    } catch (e, s) {
      stopLoading();
      print("Error removing user from the device $e");
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'a non-fatal error');
      return (
        false,
        "Tilisi on poistettu palvelimelta, mutta tietojen poistaminen laitteelta epäonnistui.\n Poista sovelluksen tiedot puhelimen asetuksista.'"
      );
    }
    stopLoading();
    return (true, "Tilisi on poistettu onnistuneesti");
  }

// #endregion

// #region Users

  Future<List<MiittiUser>> fetchUsers() async {
    QuerySnapshot querySnapshot = await _getFireQuery(_usersString);

    return querySnapshot.docs
        .map((doc) => MiittiUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  List<MiittiUser> filterUsersBasedOnArea(
      MiittiUser currentUser, List<MiittiUser> allUsers) {
    return allUsers.where((user) {
      if (user.uid == currentUser.uid) return false; // Exclude the current user

      bool sameCity = user.userArea == currentUser.userArea;

      return sameCity;
    }).toList();
  }

  List<MiittiUser> filterUsersBasedOnInterests(
      MiittiUser currentUser, List<MiittiUser> allUsers) {
    return allUsers.where((user) {
      if (user.uid == currentUser.uid) return false; // Exclude the current user

      Set<String> commonInterests = user.userFavoriteActivities
          .toSet()
          .intersection(currentUser.userFavoriteActivities.toSet());

      // If there are common interests, include the user in the list
      return commonInterests.isNotEmpty;
    }).toList();
  }

  Future<MiittiUser> getUser(String id) async {
    startLoading();
    DocumentSnapshot doc = await _getUserDoc(id);
    MiittiUser user = MiittiUser.fromDoc(doc);
    stopLoading();
    return user;
  }

  Future<CommercialUser> getCommercialUser(String id) async {
    startLoading();
    DocumentSnapshot doc =
        await _fireStore.collection("commercialUsers").doc(id).get();
    CommercialUser user =
        CommercialUser.fromMap(doc.data() as Map<String, dynamic>);
    stopLoading();
    return user;
  }

  Future<List<MiittiUser>> fetchUsersByActivityId(String activityId) async {
    try {
      // Fetch activity by id
      MiittiActivity activity =
          await _personalOrCommercial(activityId, (personActivity) async {
        return fetchUsersByUids(personActivity.participants);
      }, (commercialActivity) async {
        return fetchUsersByUids(commercialActivity.participants);
      });
      return fetchUsersByUids(activity.participants);
    } catch (e, s) {
      print("Error fetching users by activity id: $e, stack: $s");
      return [];
    }
  }

  Future<List<MiittiUser>> fetchUsersByUids(Set<String> userIds) async {
    try {
      List<MiittiUser> users = [];
      for (final uid in userIds) {
        await _tryGetUser(
            uid, (user) => users.add(user), () => print("User not found"));
      }
      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }
// #endregion

// #region Utils

  Future<QuerySnapshot> _getFireQuery(String collection) {
    return _fireStore.collection(collection).get();
  }

  Future<QuerySnapshot> _queryWhereContains(
      String collection, String array, String value) {
    return _fireStore
        .collection(collection)
        .where(array, arrayContains: value)
        .get();
  }

  Future<QuerySnapshot> _queryWhereEquals(
      String collection, String field, String value) {
    return _fireStore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
  }

  DocumentReference _userDocRef(String userId) {
    return _fireStore.collection(_usersString).doc(userId);
  }

  Future<DocumentSnapshot> _getUserDoc(String userId) {
    return _fireStore.collection(_usersString).doc(userId).get();
  }

  Future<DocumentSnapshot> _getActivityDoc(String activityId) {
    return _fireStore.collection(_activitiesString).doc(activityId).get();
  }

  DocumentReference _activityDocRef(String activityId) {
    return _fireStore.collection(_activitiesString).doc(activityId);
  }

  DocumentReference _comActivityDocRef(String activityId) {
    return _fireStore.collection(_comactString).doc(activityId);
  }

  Future<bool> _tryGetUser(
      String uid, Function(MiittiUser user) exists, Function notFound) async {
    DocumentSnapshot snapshot = await _getUserDoc(uid);
    if (snapshot.exists) {
      await exists(MiittiUser.fromDoc(snapshot));
      return true;
    } else {
      await notFound();
      return false;
    }
  }

  Future<MiittiActivity> _personalOrCommercial(
      String activityId,
      Function(PersonActivity activity) isPersonal,
      Function(CommercialActivity comActivity) isCommercial) async {
    DocumentSnapshot snapshot = await _getActivityDoc(uid);
    if (snapshot.exists) {
      PersonActivity activity = PersonActivity.fromDoc(snapshot);
      isPersonal(activity);
      return activity;
    } else {
      print("is commercial");
      DocumentSnapshot comSnapshot = await _comActivityDocRef(uid).get();
      CommercialActivity commercialActivity =
          CommercialActivity.fromDoc(comSnapshot);
      isCommercial(commercialActivity);
      return commercialActivity;
    }
  }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

// #endregion
}
