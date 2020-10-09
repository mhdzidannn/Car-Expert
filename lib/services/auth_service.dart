import 'dart:io';

import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userUID;
  AuthResultStatus _status;

  Stream<DealerDetails> getDealerProfileStream(String uid) {
    return Firestore.instance.collection("UserData").document("Dealer").collection("DealerProfile").document(uid).snapshots().map((event) {
      // print("ADA KO DAK : ${event.exists} : $userUID");
      return DealerDetails.fromMap(event.data);
    });
  }

  Stream<UserDetails> getUserProfileStream(String uid) {
    return Firestore.instance.collection("UserData").document("User").collection("UserProfile").document(uid).snapshots().map((event) => UserDetails.fromMap(event.data));
  }

  Future<DealerDetails> getDealerProfileLocal(String uid) async {
    return await Firestore.instance.collection("UserData").document("Dealer").collection("DealerProfile").document(uid).get().then((snapshot) => DealerDetails.fromMap(snapshot.data));
  }

  Future<UserDetails> getUserProfileLocal(String uid) async {
    return await Firestore.instance.collection("UserData").document("User").collection("UserProfile").document(uid).get().then((snapshot) => UserDetails.fromMap(snapshot.data));
  }

  //auth to change user stream
  Stream<User> get userStream {
    return _auth.onAuthStateChanged.map((FirebaseUser user) {
      if (user != null) {
        userUID = user.uid;
        // print("APAKAH INI SEMUA : $userUID");
        return User(uid: user.uid);
      } else {
        return null;
      }
    });
  }

  Future<DocumentSnapshot> getUserGeneralInformation() async {
    return await Firestore.instance.collection("UserData").document("User").get();
  }

  Future<DocumentSnapshot> getDealerGeneralInformation() async {
    return await Firestore.instance.collection("UserData").document("Dealer").get();
  }

  Future<bool> checkUserDetails(UserNotifier notifier) async {
    try {
      return await Future.wait(<Future<DocumentSnapshot>>[getUserGeneralInformation(), getDealerGeneralInformation()]).then((data) {
        UserGeneralInfo userInfo = UserGeneralInfo.fromMapUser(data[0].data);
        UserGeneralInfo dealerInfo = UserGeneralInfo.fromMapUser(data[1].data);
        if (dealerInfo.uid.contains(notifier.userUID)) {
          print("[Firebase] THe current user is a dealer");
          notifier.setDealerMode = true;
          return true;
        } else if (userInfo.uid.contains(notifier.userUID)) {
          print("[Firebase] THe current user is a user");
          notifier.setDealerMode = false;
          return true;
        } else {
          print("SINI PULAK DOH");
          return _auth.signOut().then((value) => false);
        }
      });
    } catch (e) {
      print("[Firebase] Error in validating user mode : ${e.toString()}");
      return false;
    }
  }

  // method to sign in with email and password
  signIn(String email, String password) async {
    try {
      final authResult = await _auth.signInWithEmailAndPassword(email: email, password: password).then((result) async {
        print("[Firebase] Logging in process completed");
      });
      if (authResult != null) {
        _status = AuthResultStatus.successful;
      } else {
        _status = AuthResultStatus.undefined;
      }
    } catch (e) {
      print('Exception caught: $e');
      _status = AuthExceptionHandler.handleException(e);
    }
    return _status;
  }

  // method to register
  Future<bool> signUpWithEmailAndPassword(
    UserNotifier notifier,
    bool isDealer,
    String email,
    String password, {
    File certificate,
    UserDetails userData,
    DealerDetails dealerData,
  }) async {
    DocumentReference user = Firestore.instance.collection("UserData").document("User");
    DocumentReference dealer = Firestore.instance.collection("UserData").document("Dealer");

    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password).then((result) async {
        if (isDealer) {
          return Firestore.instance.runTransaction((transaction) async {
            await transaction.get(dealer).then((snapshot) async {
              UserGeneralInfo recent = UserGeneralInfo.fromMapDealer(snapshot.data);
              recent.uid.add(result.user.uid);
              await transaction.update(snapshot.reference, {'UID': FieldValue.arrayUnion(recent.uid)});
            });
          }).then((_) {
            print("[FirestoreTransaction] Completed => Dealer");
            return DatabaseService().uploadSingleImage(certificate, result.user.uid).then((imageUrl) {
              dealerData.certificate = imageUrl;
              return dealer.collection("DealerProfile").document(result.user.uid).setData(dealerData.toMap()).then((_) {
                notifier.setDealerMode = true;
                notifier.setUserUID = result.user.uid;
                print("[Firebase] Successfull Registration : UserID => ${result.user.uid}");
              });
            });
          });
        } else {
          return Firestore.instance.runTransaction((transaction) async {
            await transaction.get(user).then((snapshot) async {
              UserGeneralInfo recent = UserGeneralInfo.fromMapUser(snapshot.data);
              recent.uid.add(result.user.uid);
              await transaction.update(snapshot.reference, {'UID': FieldValue.arrayUnion(recent.uid)});
            });
          }).then((_) async {
            print("[FirestoreTransaction] Completed => User");
            return await user.collection("UserProfile").document(result.user.uid).setData(userData.toMap()).then((_) {
              notifier.setDealerMode = false;
              notifier.setUserUID = result.user.uid;
              print("[Firebase] Successfull Registration : UserID => ${result.user.uid}");
              return true;
            });
          });
        }
      });
    } catch (e) {
      print("[SIGNUP] Error During Sign Up : ${e.toString()}");
      return false;
    }
  }

  // method to signout
  signOut(UserNotifier notifier) async {
    try {
      await _auth.signOut().then((_) {
        notifier.setDealerMode = null;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future editProfile(
    String uid,
    String userName,
    String phoneNumber,
    String state,
    UserNotifier notifier, {
    String firstName,
    String lastName,
    String address,
  }) async {
    if (notifier.dealerMode) {
      try {
        final CollectionReference userCollection = Firestore.instance.collection("UserData").document("Dealer").collection("DealerProfile");

        await userCollection.document(uid).updateData({
          'username': userName,
          'address': address,
          'phoneNumber': phoneNumber,
          'state': state,
        });
        await AuthService().getDealerProfileLocal(notifier.userUID).then((data) {
          notifier.notifyCurrentDealer = data;
        });
        print('Dealer Data Updated');
      } catch (e) {
        print(e.toString());
      }
    } else {
      try {
        final CollectionReference userCollection = Firestore.instance.collection("UserData").document("User").collection("UserProfile");

        await userCollection.document(uid).updateData({
          'username': userName,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'state': state,
        });
        AuthService().getUserProfileLocal(notifier.userUID).then((data) {
          notifier.notifyCurrentUser = data;
        });

        print('User Data Updated');
      } catch (e) {
        print(e.toString());
      }
    }
  }
}


enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  static handleException(e) {
    print(e.code);
    var status;
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        status = AuthResultStatus.invalidEmail;
        break;
      case "ERROR_WRONG_PASSWORD":
        status = AuthResultStatus.wrongPassword;
        break;
      case "ERROR_USER_NOT_FOUND":
        status = AuthResultStatus.userNotFound;
        break;
      case "ERROR_USER_DISABLED":
        status = AuthResultStatus.userDisabled;
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  ///
  /// Accepts AuthExceptionHandler.errorType
  ///
  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "Your login credentials are invalid.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your login credentials are invalid.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }

    return errorMessage;
  }
}