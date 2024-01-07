// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/miittiActivity.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/constants/report.dart';
import 'package:miitti_app/createMiittiActivity/activityPageFinal.dart';
import 'package:miitti_app/helpers/filter_settings.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/onboardingScreens/obs3_sms.dart';
import 'package:miitti_app/onboardingScreens/onboarding.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String? _uid;
  String get uid => _uid!;

  MiittiUser? _miittiUser;
  MiittiUser get miittiUser => _miittiUser!;

  MiittiActivity? _miittiActivity;
  MiittiActivity get miittiActivity => _miittiActivity!;

  AuthProvider() {
    checkSign();
  }

  Future<void> setUserStatus() async {
    try {
      DateTime now = DateTime.now().toUtc();
      String timestampString = now.toIso8601String();
      await _fireStore
          .collection('users')
          .doc(_uid)
          .update({'userStatus': timestampString});
      print("Userstatus set");
    } catch (e, s) {
      if (_uid == null) print("UID is null");
      print('Got an error setting user status $e and my uid is $_uid');
      print('$s');
    }
  }

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
      _isLoading = true;
      notifyListeners();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          _isLoading = false;
          notifyListeners();
          verifyOtp(
              context: context,
              verificationId: phoneAuthCredential.verificationId!,
              userOtp: phoneAuthCredential.smsCode!,
              onSuccess: () {
                checkExistingUser().then((value) async {
                  if (value == true) {
                    getDataFromFirestore().then(
                      (value) => saveUserDataToSP().then(
                        (value) => setSignIn().then(
                          (value) => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const IndexPage()),
                              (Route<dynamic> route) => false),
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const OnboardingScreen()),
                        (Route<dynamic> route) => false);
                  }
                });
              });
          debugPrint("$phoneNumber signed in");
        },
        verificationFailed: (error) {
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, "Failed phone verification: $error");

          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          _isLoading = false;
          notifyListeners();
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
      _isLoading = false;
      notifyListeners();
      debugPrint("Kirjautuminen epäonnistui: ${e.message} (${e.code})");
      showSnackBar(context, "Kirjautuminen epäonnistui: ${e.message}");
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
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
      showSnackBar(context, 'SMS vahvistus epäonnistui ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _fireStore.collection('users').doc(_uid).get();
    if (snapshot.exists) {
      return true;
    }
    return false;
  }

  void saveUserDatatoFirebase({
    required BuildContext context,
    required MiittiUser userModel,
    required File? image,
    required Function onSucess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await uploadUserImage(_firebaseAuth.currentUser!.uid, image)
          .then((value) {
        userModel.profilePicture = value;
      }).onError((error, stackTrace) {});
      userModel.userPhoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      userModel.uid = _firebaseAuth.currentUser!.uid;
      _miittiUser = userModel;

      await _fireStore
          .collection('users')
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSucess();
        _isLoading = false;
        notifyListeners();
      }).onError(
        (error, stackTrace) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      print("Userdata to firebase error: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveMiittiActivityDataToFirebase({
    required BuildContext context,
    required MiittiActivity activityModel,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      activityModel.admin = _miittiUser!.uid;
      activityModel.adminAge = calculateAge(_miittiUser!.userBirthday);
      activityModel.adminGender = _miittiUser!.userGender;
      activityModel.activityUid = generateCustomId();
      activityModel.participants.add(_miittiUser!.uid);

      _miittiActivity = activityModel;

      await _fireStore
          .collection('activities')
          .doc(activityModel.activityUid)
          .set(activityModel.toMap())
          .then((value) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ActivityPageFinal(
                miittiActivity: _miittiActivity!,
              ),
            ),
            (Route<dynamic> route) => false);

        _isLoading = false;
        notifyListeners();
      }).onError(
        (error, stackTrace) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<List<MiittiActivity>> fetchReportedActivities() async {
    try {
      QuerySnapshot querySnapshot =
          await _fireStore.collection('reportedActivities').get();

      //Create list of miittiactivities by getting reportedId value from each document in querysnapshot
      //you get activityDoc from firebase from 'activities' collection by using reportedId as doc name
      //you get MiittiActivity from activity like that: MiittiActivity.fromMap(activityDoc.data() as Map<String, dynamic>))

      List<MiittiActivity> list = [];

      for (QueryDocumentSnapshot report in querySnapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> doc =
            await _fireStore.collection("activities").doc(report.id).get();
        list.add(MiittiActivity.fromMap(doc.data() as Map<String, dynamic>));
      }

      return list;
    } catch (e) {
      print('Error fetching reported activities: $e');
      return [];
    }
  }

  Future<void> sendActivityRequest(String activityId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _fireStore.collection('activities').doc(activityId).update({
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
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> joinActivity(String activityId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _fireStore.collection('activities').doc(activityId).update({
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
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<List<MiittiActivity>> fetchActivities() async {
    try {
      FilterSettings filterSettings = FilterSettings();
      await filterSettings.loadPreferences();

      QuerySnapshot querySnapshot =
          await _fireStore.collection('activities').get();

      List<MiittiActivity> activities = querySnapshot.docs
          .map((doc) =>
              MiittiActivity.fromMap(doc.data() as Map<String, dynamic>))
          .where((activity) {
        if (_miittiUser == null) {
          print("User is null");
        } else {
          print("Checking filters of ${_miittiUser?.userName}");
          if (daysSince(activity.activityTime) < -7) {
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

      return activities;
    } catch (e, s) {
      print('Error fetching activities: $e');
      print(s);
      return [];
    }
  }

  Future<List<MiittiActivity>> fetchUserActivities() async {
    try {
      QuerySnapshot querySnapshot = await _fireStore
          .collection('activities')
          .where('participants', arrayContains: uid)
          .get();

      QuerySnapshot requestSnapshot = await _fireStore
          .collection('activities')
          .where('requests', arrayContains: uid)
          .get();

      List<MiittiActivity> activities = [];

      for (var doc in querySnapshot.docs) {
        activities
            .add(MiittiActivity.fromMap(doc.data() as Map<String, dynamic>));
      }

      for (var doc in requestSnapshot.docs) {
        activities
            .add(MiittiActivity.fromMap(doc.data() as Map<String, dynamic>));
      }

      DocumentSnapshot documentSnapshot =
          await _fireStore.collection('users').doc(_uid).get();

      MiittiUser myOwnUser =
          MiittiUser.fromMap(documentSnapshot.data() as Map<String, dynamic>);

      if (myOwnUser.invitedActivities.isNotEmpty) {
        for (String activityId in myOwnUser.invitedActivities) {
          DocumentSnapshot activitySnapshot =
              await _fireStore.collection('activities').doc(activityId).get();

          if (activitySnapshot.exists) {
            MiittiActivity activity = MiittiActivity.fromMap(
                activitySnapshot.data() as Map<String, dynamic>);
            activities.add(activity);
          }
        }
      }

      return activities;
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    }
  }

  Future<void> removeUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _fireStore
          .collection('users')
          .doc(userId)
          .delete()
          .then((value) {});

      if (!adminId.contains(_firebaseAuth.currentUser!.uid) &&
          _firebaseAuth.currentUser!.uid.isNotEmpty) {
        await _firebaseAuth.currentUser?.delete();
      }

      SharedPreferences s = await SharedPreferences.getInstance();
      _isSignedIn = false;
      _isLoading = false;
      s.clear();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error removing user from the app $e");
    }
  }

  Future removeActivity(String activityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _fireStore
          .collection('activities')
          .doc(activityId)
          .delete()
          .then((value) => print("Activity Removed!"));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleteing  activity: $e');
      return [];
    }
  }

  Future<void> removeUserFromActivity(
    String activityId,
    bool isRequested,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (!isRequested) {
        await _fireStore.collection('activities').doc(activityId).update({
          'participants': FieldValue.arrayRemove([uid])
        });
      } else {
        await _fireStore.collection('activities').doc(activityId).update({
          'requests': FieldValue.arrayRemove([uid])
        });
      }

      print("User removed from activity successfully.");

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error removing user from activity: $e');
    }
  }

  Future<List<MiittiActivity>> fetchAdminActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot querySnapshot = await _fireStore
          .collection('activities')
          .where('admin', isEqualTo: uid)
          .get();

      List<MiittiActivity> activities = querySnapshot.docs
          .map((doc) =>
              MiittiActivity.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();

      return activities;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching user activities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivitiesRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await _fireStore
          .collection('activities')
          .where('admin', isEqualTo: uid)
          .get();

      List<MiittiActivity> activities = querySnapshot.docs
          .map((doc) =>
              MiittiActivity.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      List<Map<String, dynamic>> usersAndActivityIds = [];

      for (MiittiActivity activity in activities) {
        List<MiittiUser> users = await fetchUsersByUids(activity.requests);
        usersAndActivityIds.addAll(users.map((user) => {
              'user': user,
              'activity': activity,
            }));
      }

      _isLoading = false;
      notifyListeners();

      return usersAndActivityIds.toList();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching admin activities: $e');
      return [];
    }
  }

  Future<MiittiActivity> getSingleActivity(String activityId) async {
    _isLoading = true;
    notifyListeners();
    DocumentSnapshot doc =
        await _fireStore.collection("activities").doc(activityId).get();
    MiittiActivity activity =
        MiittiActivity.fromMap(doc.data() as Map<String, dynamic>);
    _isLoading = false;
    notifyListeners();
    return activity;
  }

  Future<bool> updateUserJoiningActivity(
    String activityId,
    String userId,
    bool isOnlyDelete,
  ) async {
    _isLoading = true;
    notifyListeners();
    bool operationCompleted = false;

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
        if (!participants.contains(userId) && !isOnlyDelete) {
          participants.add(userId);
          operationCompleted = true;
        }

        transaction.update(activityRef, {
          'participants': participants,
          'requests': requests,
        });
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error while joining activity: $e');
    }
    return operationCompleted;
  }

  Future<List<MiittiUser>> fetchUsersByActivityId(String activityId) async {
    try {
      // Fetch activity by id
      DocumentSnapshot docSnapshot =
          await _fireStore.collection('activities').doc(activityId).get();
      if (!docSnapshot.exists) {
        throw Exception("Activity not found");
      }
      MiittiActivity activity =
          MiittiActivity.fromMap(docSnapshot.data() as Map<String, dynamic>);

      // Fetch participants (users) using user ids from the activity
      List<MiittiUser> users = await fetchUsersByUids(activity.participants);

      return users;
    } catch (e) {
      print("Error fetching users by activity id: $e");
      return [];
    }
  }

  Future<List<MiittiUser>> fetchUsersByUids(Set<String> userIds) async {
    try {
      List<MiittiUser> users = [];
      for (final uid in userIds) {
        DocumentSnapshot docSnapshot =
            await _fireStore.collection('users').doc(uid).get();
        if (docSnapshot.exists) {
          users.add(
              MiittiUser.fromMap(docSnapshot.data() as Map<String, dynamic>));
        }
      }
      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<bool> reactToInvite(String activityId, bool accepted) async {
    _isLoading = true;
    notifyListeners();
    bool operationCompleted = false;
    try {
      DocumentReference userRef = _fireStore.collection('users').doc(uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        MiittiUser user =
            MiittiUser.fromMap(userSnapshot.data() as Map<String, dynamic>);
        user.invitedActivities.remove(activityId);

        await userRef
            .update({'invitedActivities': user.invitedActivities.toList()});

        if (accepted) {
          await updateUserJoiningActivity(activityId, uid, false);
          operationCompleted = true;
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Found error accepting invite: $e');
    }
    return operationCompleted;
  }

  Future inviteUserToYourActivity(
    String userId,
    String activityId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get the document reference for the user who is getting invited
      DocumentReference invitedRef = _fireStore.collection('users').doc(userId);

      // Get the document snapshot of the invited user
      DocumentSnapshot invitedPersonSnapshot =
          await _fireStore.collection('users').doc(userId).get();

      if (invitedPersonSnapshot.exists) {
        // Convert the document snapshot to MiittiUser object

        MiittiUser invitedUser = MiittiUser.fromMap(
            invitedPersonSnapshot.data() as Map<String, dynamic>);

        // Add the activityId to the invitedActivities set of the invitedUser
        invitedUser.invitedActivities.add(activityId);

        // Update the 'invitedActivities' field in Firestore
        await invitedRef.update(
            {'invitedActivities': invitedUser.invitedActivities.toList()});
      }

      _isLoading = false;
      notifyListeners();
      return;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Got this error while inviting user to your activity $e');
    }
  }

  Future<bool> checkIfUserJoined(String activityUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .doc(activityUid)
        .get();

    if (snapshot.exists) {
      final activity =
          MiittiActivity.fromMap(snapshot.data() as Map<String, dynamic>);
      return activity.participants.contains(uid);
    }

    return false;
  }

  Future<bool> checkIfUserRequested(String activityUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .doc(activityUid)
        .get();

    if (snapshot.exists) {
      final activity =
          MiittiActivity.fromMap(snapshot.data() as Map<String, dynamic>);
      return activity.requests.contains(uid);
    }

    return false;
  }

  getChats(String activityId) async {
    return _fireStore
        .collection('activities')
        .doc(activityId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getGroupAdmin(String activityId) async {
    DocumentReference d = _fireStore.collection('activities').doc(activityId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  sendMessage(String activityId, Map<String, dynamic> chatMessageData) async {
    await _fireStore
        .collection('activities')
        .doc(activityId)
        .collection("messages")
        .add(chatMessageData);

    await _fireStore.collection('activities').doc(activityId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
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
    print("UG: ${_miittiUser?.userGender}");
    _uid = _miittiUser!.uid;
    notifyListeners();
  }

  Future getDataFromFirestore() async {
    await _fireStore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
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
          fcmToken: snapshot['fcmToken']);
      _uid = _miittiUser!.uid;
    }).onError((error, stackTrace) {
      print('ERROR: ${error.toString()}');
    });
  }

  Future<List<MiittiUser>> fetchUsers() async {
    QuerySnapshot querySnapshot = await _fireStore.collection('users').get();

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
    _isLoading = true;
    notifyListeners();
    DocumentSnapshot doc = await _fireStore.collection("users").doc(id).get();
    MiittiUser user = MiittiUser.fromMap(doc.data() as Map<String, dynamic>);
    _isLoading = false;
    notifyListeners();
    return user;
  }

  Future<void> updateUserInfo(MiittiUser updatedUser, File? imageFile) async {
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
        _isLoading = false;
        notifyListeners();
      });

      // Update the user in the provider

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('Error updating user info: ${e.message}');
    }
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }
}
