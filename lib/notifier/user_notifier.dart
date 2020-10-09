import 'dart:io';

import 'package:carexpert/model/advertisment.dart';
import 'package:carexpert/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class UserNotifier with ChangeNotifier {
  UserDetails _currentUser;
  DealerDetails _currentDealer;
  String _userUID;
  bool _isDealer;
  DocumentSnapshot _userDocument;
  File _profilePicture;

  List<Advertisment> userAdvertisment;

  UserDetails get getUserDetails => _currentUser;
  DealerDetails get getDealerDetails => _currentDealer;
  String get userUID => _userUID;
  bool get dealerMode => _isDealer;
  DocumentSnapshot get userDocument => _userDocument;
  File get getProfilePicture => _profilePicture;

  set setDealerMode(bool mode) {
    _isDealer = mode;
    if (_isDealer == null) {
      print("[UserNotifier] User/Dealer Mode Resetted");
    } else {
      if (_isDealer) {
        print("[UserNotifier] Currently on Dealer Mode");
      } else {
        print("[UserNotifier] Currently on User Mode");
      }
    }
  }

  set setUserUID(String uid) {
    _userUID = uid;
    print("[UserNotifier] USER UID $uid");
  }

  set userDocumentSnapshot(DocumentSnapshot doc) {
    _userDocument = doc;
    print('[UserNotifier] USER DOCUMENTS SAVE');
    notifyListeners();
  }

  set currentUser(UserDetails data) {
    _currentUser = data;
    print("[UserNotifier] MODEL INITIALIZE");
  }

  set currentDealer(DealerDetails data) {
    _currentDealer = data;
    print("[UserNotifier] MODEL INITIALIZE");
  }

  set notifyCurrentUser(UserDetails data) {
    _currentUser = data;
    print("[UserNotifier] MODEL UPDATED");
    notifyListeners();
  }

  set notifyCurrentDealer(DealerDetails data) {
    _currentDealer = data;
    print("[UserNotifier] MODEL UPDATED");
    notifyListeners();
  }

  updateUserAdvertismentList(String id) {
    _currentDealer.refDocument.removeWhere((x) => x == id);
    _currentDealer.adCount = _currentDealer.adCount - 1;
    print("[UserNotifier] {DELETE AD} => Local Data Updated");
    notifyListeners();
  }

  set setProfilePic(File profilePic) {
    _profilePicture = profilePic;
    print("[UserNotifier] Profile Picture Set");
    notifyListeners();
  }
}
