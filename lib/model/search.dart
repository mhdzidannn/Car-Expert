class Search {

  String uid;
  String plateNum;
  String refNum;
  String registrationImage;
  String carDocRef;
  String year;
  String location;
  String adTitle;
  String adDescription;
  int mileage;
  int price;
  List<String> carIamges;

  Search();

  Search.fromMap(Map<String, dynamic> data) {
    uid = data['UID'];
    plateNum = data['PlateNum'];
    refNum = data['RefNum'];
    registrationImage = data['RegistrationCard'];
    year = data['year'];
    carDocRef = data['CarRef'];
    location = data['Location'];
    adTitle = data['AdsTitle'];
    adDescription = data['AdsDesc'];
    mileage = data['Mileage'];
    price = data['Price'];
  }

}