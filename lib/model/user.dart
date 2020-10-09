class User {
  final String uid;

  User({this.uid});
}

class DealerDetails {
  String uid;
  String username;
  String state;
  String phone;
  String email;
  String profilePic;
  String address;
  String certificate;
  int adCount;
  List refDocument;
  List likeNotification;

  DealerDetails({
    this.username,
    this.state,
    this.phone,
    this.email,
    this.profilePic,
    this.address,
    this.certificate,
    this.adCount,
    this.refDocument,
  });

  DealerDetails.fromMap(Map<String, dynamic> data) {
    username = data['username'];
    certificate = data['certificate'];
    profilePic = data['profilePic'];
    email = data['email'];
    phone = data['phone'];
    state = data['state'];
    address = data['address'];
    refDocument = data['refDocument'];
    adCount = data['adCount'];
    likeNotification = data['likeNotification'];
  }

  DealerDetails.fromMapUser(Map<String, dynamic> data, String uidData) {
    uid = uidData;
    username = data['username'];
    certificate = data['certificate'];
    profilePic = data['profilePic'];
    email = data['email'];
    phone = data['phone'];
    state = data['state'];
    address = data['address'];
    refDocument = data['refDocument'];
    adCount = data['adCount'];
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'certificate': certificate,
      'profilePic': profilePic,
      'email': email,
      'phone': phone,
      'state': state,
      'address': address,
      'refDocument': refDocument,
      'adCount': adCount,
      'likeNotification' : likeNotification
    };
  }
}

class UserDetails {
  String username;
  String state;
  String phone;
  String email;
  String profilePic;
  String firstName;
  String lastName;
  List uidSeller;
  List likedCars;
  List deletedCars;
  String dealerUID;

  UserDetails({
    this.username,
    this.state,
    this.phone,
    this.email,
    this.profilePic,
    this.firstName,
    this.lastName,
    this.uidSeller,
    this.likedCars,
    this.dealerUID,
  });

  UserDetails.fromMap(Map<String, dynamic> data) {
    firstName = data['firstname'];
    lastName = data['lastname'];
    username = data['username'];
    profilePic = data['profilePic'];
    email = data['email'];
    phone = data['phone'];
    state = data['state'];
    likedCars = data['likeCars'];
    uidSeller = data['uidSeller'];
    deletedCars = data['deletedCars'];
  }

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'profilePic': profilePic,
      'email': email,
      'phone': phone,
      'state': state,
      'likeCars': likedCars,
      'uidSeller': uidSeller,
      'deletedCars': deletedCars
    };
  }

  set setDealerUID(String uid) {
    dealerUID = uid;
  }
}

class UserGeneralInfo {
  //SHARED DATA
  List uid;

  //DEALER
  List carDocRef;
  int adCount;

  UserGeneralInfo();

  UserGeneralInfo.fromMapUser(Map<String, dynamic> data) {
    uid = data['UID'];
  }

  UserGeneralInfo.fromMapDealer(Map<String, dynamic> data) {
    uid = data['UID'];
    carDocRef = data["CarDocument"];
    adCount = data["Adcount"];
  }
}
